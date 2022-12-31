provider "aws" {
  region = "ap-northeast-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "dy-tf-prod" # prod
  instance_type = "m4.large"
  key_pair = "dy-tf-dev"
  server_port = 8080
  min_size = 2
  max_size = 10

  # db reference info
  db_remote_state_bucket = "dy-tf-state"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate" # prod
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 5
  recurrence = "0 9 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = module.webserver_cluster.asg_name
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