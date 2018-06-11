variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  default     = "10.0.128.0/20"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  default     = "10.0.0.0/19"
}

variable "aws_region" {
  description = "The region to launch the bastion host"
  default     = "eu-west-3"
}

variable "availability_zone" {
  description = "The az that the resources will be launched"
  default     = "eu-west-3a"
}

variable "key_name" {
  description = "Key for the bastion host instance"
  default     = "npakhol"
}
