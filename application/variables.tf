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

variable "ECS_SERVICE_NAME" {}
variable "TASK_DEFINITION_NAME" {}
variable "DOCKER_IMAGE_URL" {}
variable "SPRING_PROFILE" {}
variable "DOCKER_CONTAINER_PORT" {}
variable "TASK_MEMORY" {}
variable "TASK_CPU" {}


