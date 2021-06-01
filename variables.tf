# Common
variable "prefix" {}

variable "aws_profile" {}

variable "aws_region" {
  default = "ap-northeast-1"
}

variable "tags" {
  default = {
    project = "cloud02"
    env     = "dev"
  }
}

# EC2
variable "allowed_cidr" {
  default = null
}

# Route53
variable "my_domain" {}
