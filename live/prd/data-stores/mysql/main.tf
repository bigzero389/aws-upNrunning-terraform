provider "aws" {
  region = "ap-northeast-2"
}

locals {
  system_name = "${var.cluster_name}-${var.environment}"
}

module "mysql" {
  source = "../../../../modules/data-stores/mysql"

  vpc_id = data.aws_vpc.default.id

  cluster_name = var.cluster_name # dy-tf
  environment = var.environment # prd

  instance_type = "db.t2.micro"
  admin_username = "admin"
  db_password = var.password
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
    key = "prd/data-stores/mysql/terraform.tfstate"  # prod
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}
