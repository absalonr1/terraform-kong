terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-bx"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.region
  profile = "qaaccess"
}