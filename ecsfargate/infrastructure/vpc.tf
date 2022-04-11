provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

resource "aws_vpc" "fargate_course_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "ECS-FARGATE-VPC"
  }
}

resource "aws_subnet" "public_subnet-1" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ECS-FARGATE-VPC-PUBLIC-SUBNET-1"
  }
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = "eu-west-2b"

  tags = {
    Name = "ECS-FARGATE-VPC-PUBLIC-SUBNET-2"
  }
}

resource "aws_subnet" "public_subnet-3" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = "eu-west-2c"

  tags = {
    Name = "ECS-FARGATE-VPC-PUBLIC-SUBNET-3"
  }
}

resource "aws_subnet" "private_subnet-1" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name = "ECS-FARGATE-VPC-PRIVATE-SUBNET-1"
  }
}

resource "aws_subnet" "private_subnet-2" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "eu-west-2b"

  tags = {
    Name = "ECS-FARGATE-VPC-PRIVATE-SUBNET-2"
  }
}

resource "aws_subnet" "private_subnet-3" {
  vpc_id            = aws_vpc.fargate_course_vpc.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = "eu-west-2c"

  tags = {
    Name = "ECS-FARGATE-VPC-PRIVATE-SUBNET-3"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.fargate_course_vpc.id

  tags = {
    Name = "ECS-FARGATE-VPC-PUBLIC-ROUTE-TABLE"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.fargate_course_vpc.id

  tags = {
    Name = "ECS-FARGATE-VPC-PRIVATE-ROUTE-TABLE"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet-1.id
}


resource "aws_route_table_association" "public_subnet_2_route_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet-2.id
}


resource "aws_route_table_association" "public_subnet_3_route_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet-2.id
}

resource "aws_route_table_association" "private_subnet_1_route_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet-1.id
}


resource "aws_route_table_association" "private_subnet_2_route_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet-2.id
}


resource "aws_route_table_association" "private_subnet_3_route_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet-3.id
}

resource "aws_eip" "nat-gw-eip" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "ECS-FARGATE-COURSE-EIP"
  }
}

resource "aws_nat_gateway" "courseNatGateway" {
  allocation_id = aws_eip.nat-gw-eip.id
  subnet_id     = aws_subnet.public_subnet-1.id

  tags = {
    Name = "ECS-FARGATE-COURSE-NAT-GW"
  }

  depends_on = [aws_eip.nat-gw-eip]
}

resource "aws_route" "nat-gw-route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.courseNatGateway.id
  destination_cidr_block = "0.0.0.0/0"
}


resource "aws_internet_gateway" "courseInternetGW" {
  vpc_id = aws_vpc.fargate_course_vpc.id

  tags = {
    Name = "ECS-FARGATE-COURSE-IGW"
  }
}


resource "aws_route" "igw-route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.courseInternetGW.id
  destination_cidr_block = "0.0.0.0/0"
}