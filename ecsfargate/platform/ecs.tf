provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "networkInfrastructure" {
  backend = "s3"

  config = {
    region = var.aws_region
    bucket = var.infrastructureStateBucket
    key    = var.infrastructureStateKey
  }
}

resource "aws_ecs_cluster" "fargate-course-cluster" {
  name = var.clusterName
}

resource "aws_security_group" "alb-security-group" {
  name        = "${var.clusterName}-ALB-SG"
  description = "alb-security-group"
  vpc_id      = data.terraform_remote_state.networkInfrastructure.outputs.vpc_id

  ingress {
    from_port   = 443
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = [var.alb-sf-cidr-blocks]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = [var.alb-sf-cidr-blocks]
  }
}

resource "aws_alb" "fargates_cluster_alb" {
  name            = "${var.clusterName}-ALB"
  internal        = false
  security_groups = [aws_security_group.alb-security-group.id]
  subnets         = data.terraform_remote_state.networkInfrastructure.outputs.public_subnets
}

resource "aws_alb_target_group" "fargates_cluster_alb_tg" {
  name     = "${var.clusterName}-ALB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networkInfrastructure.outputs.vpc_id
}

resource "aws_alb_listener" "fargates_cluster_alb_tg" {
  load_balancer_arn = aws_alb.fargates_cluster_alb.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.fargates_cluster_alb_tg.arn
  }

  depends_on = [aws_alb_target_group.fargates_cluster_alb_tg]
}

resource "aws_iam_role" "fargates_cluster_iamrole" {
  name               = "${var.clusterName}-IAM-ROLE"
  assume_role_policy = <<EOF
    {
      "Version":"2012-10-17",
      "Statement":[
        {
          "Effect":"Allow",
          "Principal":
          {
            "Service":["ecs.amazonaws.com", "ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
          },
          "Action":"sts:AssumeRole"
        }
      ]
    }
  EOF
}

resource "aws_iam_role_policy" "ecs-course-cluster-iamrole-policy" {
  name   = "${var.clusterName}-iam-policy"
  role   = aws_iam_role.fargates_cluster_iamrole.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*",
        "ec2:*",
        "elasticloadbalancing:*",
        "ecr:*",
        "dynamodb:*",
        "cloudwatch:*",
        "s3:*",
        "rds:*",
        "sqs:*",
        "sns:*",
        "logs:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}