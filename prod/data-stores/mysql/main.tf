provider "aws" {
  region = "ap-northeast-2"
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"

  db_password = var.password
  cluster_name = "dy-tf-prod" # prod
  instance_type = "db.t2.micro"
  admin_username = "admin"

  # db_remote_state_bucket = "dy-tf-state"
  # db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}

terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "prod/data-stores/mysql/terraform.tfstate"  # prod
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}