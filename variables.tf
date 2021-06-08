# Common
variable "prefix" {}

variable "aws_profile" {}

variable "aws_region" {
  default = "ap-northeast-1"
}

# VPC
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# EC2
variable "allowed_cidr" {
  default = null
}

# Route53
variable "my_domain" {}
