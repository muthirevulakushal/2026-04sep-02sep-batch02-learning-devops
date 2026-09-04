# Create VPC 
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.full_cidr
  instance_tenancy = "default"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "main_vpc"
  }
}