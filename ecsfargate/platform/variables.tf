variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "aws_region"
}

variable "infrastructureStateBucket" {
  type = string
}


variable "infrastructureStateKey" {
  type = string
}

variable "clusterName" {
  type = string
}

variable "alb-sf-cidr-blocks" {
  type = string
}