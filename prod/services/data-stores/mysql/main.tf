provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "dy-tf"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  db_name = "dy_tf_ex_database"
  username = "admin"

  # password = data.aws_secretsmanager_secret_version.db_password.secrete_string
  password = var.db_password  # gjeodud01, 특수문자안됨
}

# AWS Secret Manager 에 보안값을 넣고 읽어들여서 사용한다.
# data "aws_secretsmanager_secret_version" "db_password" {
#   secret_id = "mysql-master-password-stage"
# }

terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}