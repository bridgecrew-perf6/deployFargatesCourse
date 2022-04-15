variable "aws_region" {
  default     = "eu-west-2"
  type        = string
  description = "aws_region"
}

variable "vpc_cidr" {
  description = "vpc_cidr"
}

variable "public_subnet_1_cidr" {
  description = "public_subnet_1_cidr"
}

variable "public_subnet_2_cidr" {
  description = "public_subnet_2_cidr"
}

variable "public_subnet_3_cidr" {
  description = "public_subnet_3_cidr"
}

variable "private_subnet_1_cidr" {
  description = "private_subnet_1_cidr"
}

variable "private_subnet_2_cidr" {
  description = "private_subnet_2_cidr"
}

variable "private_subnet_3_cidr" {
  default = "private_subnet_3_cidr"
}