variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "aws_region"
}

variable "platformStateBucket" {
  type = string
}


variable "platformStateKey" {
  type = string
}

variable "ecs_service_name" {}
variable "docker_image_url" {}
variable "docker_container_port" {}

