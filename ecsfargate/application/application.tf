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

