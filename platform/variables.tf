variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "aws_region"
}

variable "networkStateBucket" {
  type = string
}

variable "networkStateKey" {
  type = string
}

variable "clusterName" {
  type = string
}

variable "alb-sf-cidr-blocks" {
  type = string
}