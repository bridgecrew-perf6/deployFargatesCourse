output "vpc_id" {
  value = data.terraform_remote_state.networkInfrastructure.outputs.vpc_id
}

output "vpc_cidr_block" {
  value = data.terraform_remote_state.networkInfrastructure.outputs.vpc_cidr_block
}

output "public_subnets" {
  value = data.terraform_remote_state.networkInfrastructure.outputs.public_subnets
}

output "private_subnets" {
  value = data.terraform_remote_state.networkInfrastructure.outputs.private_subnets
}

output "ecs_alb_listener_arn" {
  value = aws_alb_listener.fargates_cluster_alb_tg.arn
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.fargate-course-cluster.name
}

output "ecs_cluster_role_name" {
  value = aws_iam_role.fargates_cluster_iamrole.name
}

output "ecs_cluster_role_arn" {
  value = aws_iam_role.fargates_cluster_iamrole.arn
}

