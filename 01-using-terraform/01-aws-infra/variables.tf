variable "region" {
  default     = "us-east-2"
  description = "Primary Region"
}

variable "full_cidr" {
  default     = "192.168.0.0/16"
  description = "Main VPC Full CIDR"
}

variable "zoneA" {
  default = "us-east-2a"
}

variable "zoneB" {
  default = "us-east-2b"
}


variable "ami_id" {
  description = "Default AMI ID from us-east-2"
  default     = "ami-085f9c64a9b75eed5"
}

variable "instance_type" {
  description = "Default Instance Size from us-east-2"
  default     = "t2.micro"
}

variable "key_name" {
  default = "kp"
  description = "Key Pair Used to provision and connect with Instances"
}

variable "ami_map" {
  type = map(string)
  default = {
    "dev"  = "ami-085f9c64a9b75eed5" # For Dev, AMI requried to choosen
    "prod" = "ami-0139963043080810f" # For Prod,AMI required to chosen
  }

}

variable "env" {
  default     = "dev"
  description = "Default Env"
}

variable "bucket_name" {
  default     = "admin-terraform-bucket"
  description = "S3 Bucket Name"
}