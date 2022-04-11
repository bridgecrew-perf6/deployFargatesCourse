output "vpc_id" {
  value = aws_vpc.fargate_course_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.fargate_course_vpc.cidr_block
}

output "public_subnet_1_cidr_block" {
  value = aws_subnet.public_subnet-1.cidr_block
}

output "public_subnet_2_cidr_block" {
  value = aws_subnet.public_subnet-2.cidr_block
}

output "public_subnet_3_cidr_block" {
  value = aws_subnet.public_subnet-3.cidr_block
}

output "private_subnet_1_cidr_block" {
  value = aws_subnet.private_subnet-1.cidr_block
}


output "private_subnet_2_cidr_block" {
  value = aws_subnet.private_subnet-2.cidr_block
}

output "private_subnet_3_cidr_block" {
  value = aws_subnet.private_subnet-3.cidr_block
}