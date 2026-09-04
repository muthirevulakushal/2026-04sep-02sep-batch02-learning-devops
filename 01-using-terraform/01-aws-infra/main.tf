terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
  backend "s3" {
    bucket = "alpha-bt-us-east-2"
    key    = "instance/terraform.tfstate"
    region = "us-east-2"
  }
}


provider "aws" {
  region = var.region
}
