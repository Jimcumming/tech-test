#=======================================================================================================================
# ECR
#=======================================================================================================================

resource "aws_ecr_repository" "dashboard_ecr" {
  name                 = "dashboard"
  image_tag_mutability = "MUTABLE"
}

#=======================================================================================================================
# ECS
#=======================================================================================================================

resource "aws_ecs_cluster" "cluster" {
  name = "applications-cluster"
}

resource "aws_iam_role" "execution_role" {
  name = "execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowECSAssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_ecs_task_definition" "dashboard" {
  family                   = "dashboard"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.execution_role.arn
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "name": "dashboard",
      "image": "nginx",
      "cpu": 512,
      "memory": 1024,
      "essential": true,
      "portMappings": [
        {
          "hostPort": 80,
          "protocol": "tcp",
          "containerPort": 80
        }
      ]
    }
  ]
  TASK_DEFINITION
}

resource "aws_security_group" "ecs_service" {
  vpc_id = module.vpc.vpc_id
  name   = "ECS service security group"

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "dashboard" {
  name            = "dashboard"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.dashboard.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  iam_role        = null

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "dashboard"
    container_port   = 80
  }

  network_configuration {
    security_groups  = [aws_security_group.ecs_service.id]
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }

  deployment_controller {
    type = "ECS"
  }

}

#=======================================================================================================================
# Application Load Balancer
#=======================================================================================================================

resource "aws_security_group" "loadbalancer_sg" {
  name   = "allow_http"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_lb" "loadbalancer" {
  name               = "dashboard-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "main" {
  name        = "http-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "Not found."
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

#=======================================================================================================================
# DNS
#=======================================================================================================================

data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "domain" {
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "864000"
  zone_id = data.aws_route53_zone.zone.id
  records = [aws_lb.loadbalancer.dns_name]
}