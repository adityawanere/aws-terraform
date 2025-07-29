output "ec2_instance_id" {
  value       = aws_instance.react_site_ec2_instance.id
  description = "The ID of the EC2 instance."
}

output "ecr_name" {
  value = aws_ecr_repository.my_ecr_registry.name
}

output "ecr_id" {
  value = aws_ecr_repository.my_ecr_registry.id
}

output "ecr_repo_name" {
  value = aws_ecr_repository.my_ecr_registry.repository_url
}
