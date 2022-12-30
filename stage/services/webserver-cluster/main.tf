provider "aws" {
	region = "ap-northeast-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "dy-tf-stage"  # stage
  instance_type = "t2.micro"
  key_pair = "dy-tf-dev"
  server_port = 8080
  min_size = 2
  max_size = 2

  # db reference info
  db_remote_state_bucket = "dy-tf-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate" # stage
}

# terraform 백엔드 구성
terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}