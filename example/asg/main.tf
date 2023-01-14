provider "aws" {
  region = "ap-northeast-2"
}

locals {
  system_name = "${var.cluster_name}-${var.environment}"
}

module "asg" {
  source = "../../modules/cluster/asg-rolling-deploy"

  vpc_id = data.aws_vpc.default.id

  cluster_name = var.cluster_name
  environment = var.environment
  ami = "ami-06eea3cd85e2db8ce"
  instance_type = "t2.micro"
  key_pair = "dy-tf-dev"

  min_size = 1
  max_size = 1
  enable_autoscaling = false
  
  subnet_ids = data.aws_subnets.default.ids

  give_user_cloudwatch_full_access = true

  db_remote_state_bucket = "dy-tf-state"
  db_remote_state_key    = "stg/data-stores/mysql/terraform.tfstate"
}

data "aws_vpc" "default" {
  tags = {
    Name = "${local.system_name}-vpc"
  }
}

# TAG NAME 으로 subnet 을 가져온다.
data "aws_subnets" "default" {
  filter {
    name = "tag:Name"
    values = ["${local.system_name}-sb-public-*"]
  }
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
