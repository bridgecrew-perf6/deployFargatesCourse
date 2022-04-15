provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "platformInfrastructure" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.platformStateBucket
    key    = var.platformStateKey
  }
}


data "template_file" "fargate_task_definition_template" {
  template = file("task_definition.json")

  vars = {
    docker_image_url = var.docker_image_url
  }
}

resource "aws_ecs_task_definition" "spring_app_task" {
  container_definitions    = data.template_file.fargate_task_definition_template.rendered
  family                   = var.ecs_service_name
  memory                   = "512"
  cpu                      = "256"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_iamrole.arn
  task_role_arn            = aws_iam_role.ecs_task_iamrole.arn
}

resource "aws_iam_role" "ecs_task_iamrole" {
  name               = "${var.ecs_service_name}-IAM-ROLE"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
 {
   "Effect": "Allow",
   "Principal": {
     "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
   },
   "Action": "sts:AssumeRole"
  }
  ]
 }
EOF
}


resource "aws_iam_role_policy" "ecs-task-iamrole-policy" {
  name   = "${var.ecs_service_name}-iam-policy"
  role   = aws_iam_role.ecs_task_iamrole.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ecr:*",
        "logs:*",
        "cloudwatch:*",
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_security_group" "spring-app-security-group" {
  name        = "${var.ecs_service_name}-APP-SG"
  description = "SG IN/OUT SPRING APP"
  vpc_id      = data.terraform_remote_state.platformInfrastructure.outputs.vpc_id

  ingress {
    from_port   = 8080
    protocol    = "TCP"
    to_port     = 8080
    cidr_blocks = [data.terraform_remote_state.platformInfrastructure.outputs.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group" "ecs-task-target-group" {
  name        = "${var.ecs_service_name}-ALB-TG"
  port        = var.docker_container_port
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.platformInfrastructure.outputs.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
  }
}

resource "aws_ecs_service" "spring_app_ecs_service" {
  name            = var.ecs_service_name
  task_definition = aws_ecs_task_definition.spring_app_task.id
  desired_count   = 1
  cluster         = data.terraform_remote_state.platformInfrastructure.outputs.ecs_cluster_name
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.platformInfrastructure.outputs.public_subnets
    security_groups  = [aws_security_group.spring-app-security-group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.ecs_service_name
    container_port   = var.docker_container_port
    target_group_arn = aws_alb_target_group.ecs-task-target-group.arn
  }
}

resource "aws_alb_listener_rule" "spring-app-listener-rule" {
  listener_arn = data.terraform_remote_state.platformInfrastructure.outputs.ecs_alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-task-target-group.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_cloudwatch_log_group" "spring-app-cloudwatch-group" {
  name = "${var.ecs_service_name}-logs-group"
}