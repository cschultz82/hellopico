#Application Load Balancer
resource "aws_alb" "sample-load-balancer" {
  idle_timeout       = "60"
  internal           = false
  load_balancer_type = "application"
  name               = "sample-load-balancer"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.sample-load-balancer-sg.id]
  subnets            = [aws_subnet.sample-public-subnet.id, aws_subnet.sample-private-subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "sample-alb"
  }
}

#Target Group for ALB
resource "aws_alb_target_group" "sample-target-group" {
  name            = "sample-target-group"
  port            = "80"
  target_type     = "ip"
  protocol        = "HTTP"
  ip_address_type = "ipv4"
  vpc_id          = aws_vpc.sample-vpc.id
  tags = {
    Name = "sample-alb-target-group"
  }
  health_check {
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}

#Listener for ALB
resource "aws_alb_listener" "ecs-alb-http-listener" {
  load_balancer_arn = aws_alb.sample-load-balancer.arn

  port     = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.users-target-group.arn
  }
  tags = {
    Name = "sample-alb-listener"
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_alb_target_group.sample-target-group.arn
  target_id        = aws_ecs_service.sample-service.id
  vpc_id           = aws_vpc.sample-vpc.id
  port             = 80
  depends_on = [
    aws_ecs_service.sample-service
  ]
}



#Rule for ALB Listener
#resource "aws_lb_listener_rule" "host_based_weighted_routing" {
#  listener_arn = aws_lb_listener.ecs-alb-http-listener.arn
#  priority     = 1
#
#  action {
#    type             = "forward" 
#   target_group_arn = aws_alb_target_group.sample-target-group.arn
#  }
#
#  condition {
#    host_header {
#      values = ["<conditional>"]
#    }
#  }
#}

#HTTPS SSL config
# resource "aws_lb_listener" "front_end" {
#  load_balancer_arn = aws_alb.sample-load-balancer.arn
#  port              = "443"
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#
#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.front_end.arn
#  }
#}


#Route53Record

#resource "aws_route53_record" "sample-service-local-A" {
#  zone_id         = "Z02682623MDVUW5I3D7A4"
#  name            = "sample-service-r53"
#  type            = "A"
#  records         = ["10.0.0.172"]
#  ttl             = "60"
#  set_identifier  = "e7f11abeed0e4bffa23ede02fa87ca11"
#  health_check_id = "4951e2ef-04a5-4bf2-b51e-c434c225ba13"
#}
