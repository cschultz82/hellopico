
# Create ECR repository
resource "aws_ecr_repository" "hellopico" {
  name = "hellopico"
}

# Build and push image to ECR
data "aws_ecr_authorization_token" "ecr_token" {
  depends_on = [aws_ecr_repository.hellopico]
}

# Multiple docker push commands can be run against a single token
resource "null_resource" "renew_ecr_token" {
  depends_on = [aws_ecr_repository.hellopico]

  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login --password-stdin --username AWS \"$(aws sts get-caller-identity --query Account --output text --profile personalaccount).dkr.ecr.us-east-1.amazonaws.com\" "
  }

  provisioner "local-exec" {
    command = "docker build -t hellopico . --no-cache"
  }

  provisioner "local-exec" {
    command = "docker tag hellopico:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hellopico:latest"
  }

  provisioner "local-exec" {
    command = "docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/hellopico:latest"
  }

}


#ECS Cluster
resource "aws_ecs_cluster" "sample-cluster" {
  name = "sample-cluster"
}


#ECS Task Definition
resource "aws_ecs_task_definition" "sample-task-definition" {
  family             = "sample-task-definition" # Naming our first task
  execution_role_arn = "arn:aws:iam::224697059325:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      executionRoleArn = "arn:aws:iam::224697059325:role/ecsTaskExecutionRole"
      name             = "sample-container",
      image            = "224697059325.dkr.ecr.us-east-1.amazonaws.com/hellopico:latest",
      cpu              = 0.25,
      memory           = 0.5,
      essential        = true,
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/sample-task-definition",
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      }
  }])
  memory        = 0.5
  task_role_arn = "arn:aws:iam::224697059325:role/ecsTaskExecutionRole"
  #compatibilities   = ["EC2", "FARGATE"]
  #taskDefinitionArn = "arn:aws:ecs:us-east-1:224697059325:task-definition/sample-task-definition:1"
  requires_attributes = [
    {
      name = "com.amazonaws.ecs.capability.logging-driver.awslogs"
    },
    {
      name = "ecs.capability.execution-role-awslogs"
    },
    {
      name = "com.amazonaws.ecs.capability.ecr-auth"
    },
    {
      name = "com.amazonaws.ecs.capability.docker-remote-api.1.19"
    },
    {
      name = "com.amazonaws.ecs.capability.docker-remote-api.1.21"
    },
    {
      name = "com.amazonaws.ecs.capability.task-iam-role"
    },
    {
      name = "ecs.capability.execution-role-ecr-pull"
    },
    {
      name = "com.amazonaws.ecs.capability.docker-remote-api.1.18"
    },
    {
      name = "ecs.capability.task-eni"
    }
  ]
  requires_compatibilities = [
    "FARGATE"
  ]
  network_mode = "awsvpc"
  cpu          = 0.25
}


#ECS Service
resource "aws_ecs_service" "sample-service" {
  name            = "sample-service"
  cluster         = aws_ecs_cluster.sample-cluster.id
  task_definition = aws_ecs_task_definition.sample-task-definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  iam_role        = "arn:aws:iam::224697059325:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
  depends_on      = [aws_iam_role_policy.ecs_service_role]
  load_balancer {
    target_group_arn = aws_alb_target_group.sample-target-group.arn
    container_name   = "sample-container"
    container_port   = 80
  }
  network_configuration = {
    subnets          = [aws_subnet.sample-public-subnet.id, aws_subnet.sample-private-subnet.id]
    security_groups  = [aws_security_group.sample-load-balancer-sg.id]
    assign_public_ip = true
  }
}


