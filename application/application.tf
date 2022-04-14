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
  template = file("fargate_task_definition.json")

  vars = {
    ECS_SERVICE_NAME      = var.ECS_SERVICE_NAME
    TASK_DEFINITION_NAME  = var.TASK_DEFINITION_NAME
    DOCKER_IMAGE_URL      = var.DOCKER_IMAGE_URL
    SPRING_PROFILE        = var.SPRING_PROFILE
    DOCKER_CONTAINER_PORT = var.DOCKER_CONTAINER_PORT
    REGION                = var.aws_region

  }
}

resource "aws_ecs_task_definition" "spring-app-task" {
  container_definitions    = data.template_file.fargate_task_definition_template.rendered
  family                   = var.ECS_SERVICE_NAME
  cpu                      = var.TASK_CPU
  memory                   = var.TASK_MEMORY
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_iamrole.arn
  task_role_arn            = aws_iam_role.ecs_task_iamrole.arn
}

resource "aws_iam_role" "ecs_task_iamrole" {
  name               = "${var.ECS_SERVICE_NAME}-IAM-ROLE"
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
  name   = "${var.ECS_SERVICE_NAME}-iam-policy"
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
  name        = "${var.ECS_SERVICE_NAME}-APP-SG"
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
  name        = "${var.ECS_SERVICE_NAME}-ALB-TG"
  port        = var.DOCKER_CONTAINER_PORT
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
  name            = var.ECS_SERVICE_NAME
  task_definition = aws_ecs_task_definition.spring-app-task.id
  desired_count   = 1
  cluster         = data.terraform_remote_state.platformInfrastructure.outputs.ecs_cluster_name
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.terraform_remote_state.platformInfrastructure.outputs.public_subnets
    security_groups  = [aws_security_group.spring-app-security-group.id]
    assign_public_ip = true
  }

  load_balancer {
    container_name   = var.ECS_SERVICE_NAME
    container_port   = var.DOCKER_CONTAINER_PORT
    target_group_arn = aws_alb_target_group.ecs-task-target-group.arn
  }
}

resource "aws_alb_listener_rule" "spring-app-listener-rule" {
  listener_arn = data.terraform_remote_state.platformInfrastructure.outputs.ecs_alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-task-target-group.arn
  }
  condition {}
}

resource "aws_cloudwatch_log_group" "spring-app-cloudwatch-group" {
  name = "${var.ECS_SERVICE_NAME}-logs-group"
}