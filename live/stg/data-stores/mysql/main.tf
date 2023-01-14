provider "aws" {
  region = "ap-northeast-2"
}

module "mysql" {
  # source = "git@github.com:largezero/tf-upNrunning//modules/data-stores/mysql?ref=v0.0.2"
  source = "../../../../modules/data-stores/mysql"

  db_password = var.password
  cluster_name = var.cluster_name # stg
  environment = var.environment # stg
  instance_type = "db.t2.micro"
  admin_username = "admin"

  # db_remote_state_bucket = "dy-tf-state"
  # db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
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

