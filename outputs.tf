output "alb_hostname" {
  value = aws_alb.sample-load-balancer.dns_name
}
