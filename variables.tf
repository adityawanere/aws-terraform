variable "instance_type" {
  default     = "t3.micro"
  type        = string
  description = "Type of EC2 instance"
}

variable "key_name" {
  description = "Access Key ID"
}

# variable "public_key_path" {
#   description = "Path to public key (.pub)"
#   type        = string
# }
