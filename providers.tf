terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  # backend config to store mystate
  backend "s3" {
    bucket = "adi-s3-bucket-01"
    key    = "terrafrom-state/terraform.tfstate"
    region = "ap-south-1"
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "ap-south-1"
  # alias  = "mumbai"
}
