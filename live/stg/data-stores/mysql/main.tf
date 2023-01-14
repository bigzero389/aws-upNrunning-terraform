provider "aws" {
  region = "ap-northeast-2"
}

locals {
  system_name = "${var.cluster_name}-${var.environment}"
}

module "mysql" {
  # source = "git@github.com:largezero/tf-upNrunning//modules/data-stores/mysql?ref=v0.0.2"
  source = "../../../../modules/data-stores/mysql"

  vpc_id = data.aws_vpc.default.id

  db_password = var.password
  cluster_name = var.cluster_name # dy-tf
  environment = var.environment # stg
  instance_type = "db.t2.micro"
  admin_username = "admin"
}

data "aws_vpc" "default" {
  #default = true
  tags = {
    Name = "${local.system_name}-vpc"
  }
}


terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "stg/data-stores/mysql/terraform.tfstate" # stage
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}

