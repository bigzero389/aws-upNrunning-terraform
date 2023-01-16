variable "region" {
  description = "Set AWS Region"
  type = string
  default = "ap-northeast-2"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/networking/vpc"

  region = var.region
  cluster_name = "dy-tf"
  environment = "ex"
  creator = "dyheo"
  group = "cloudteam"
  azs = {
    "${var.region}a" = "a"
    "${var.region}c" = "c"
  }
  public_subnets = {
    "${var.region}a" = "10.77.101.0/24"
#    "${var.region}b" = "10.66.102.0/24"
    "${var.region}c" = "10.77.103.0/24"
  }
  private_subnets = {
#    "${var.region}a" = "10.77.111.0/24"
#    "${var.region}b" = "10.66.112.0/24"
    "${var.region}c" = "10.77.113.0/24"
  }
  cidr_block = "10.77.0.0/16"
}

output "aws_vpc_id" {
  value = module.vpc.aws_vpc_id
}

output "aws_public_subnet_id" {
  value = module.vpc.aws_public_subnet_id
}

output "aws_private_subnet_id" {
  value = module.vpc.aws_private_subnet_id
}

terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "examples/vpc/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}