provider "aws" {
  region = "ap-northeast-2"
}

module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name = "dy-tf-prod" # prod
  instance_type = "m4.large"
  key_pair = "dy-tf-dev"
  server_port = 8080
  min_size = 2
  max_size = 10
  enable_autoscaling = true
  give_user_cloudwatch_full_access = false
  enable_new_user_data = false

  # db reference info
  db_remote_state_bucket = "dy-tf-state"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate" # prod

  custom_tags = {
    Owner = "bigzero-tf"
    DeployedBy = "Terraform"
  }
}

# terraform 백엔드 구성
terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "prod/services/webserver-cluster/terraform.tfstate" # prod
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}