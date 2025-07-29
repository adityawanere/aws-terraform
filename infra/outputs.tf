output "ec2_instance_id" {
  value       = aws_instance.react_site_ec2_instance.id
  description = "The ID of the EC2 instance."
}
