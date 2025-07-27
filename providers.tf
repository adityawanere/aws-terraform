terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = "ap-south-1"
  alias  = "mumbai"
}
