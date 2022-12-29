# provider "aws" {
#   region = "ap-northeast-2"
# }

locals {
  db_service_port = 3306
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "HTTP"
  https_protocol = "HTTPS"
  all_ips = ["0.0.0.0/32"]
  home_cidr = "125.177.68.23/32"
  work_cidr = "211.206.114.80/32"
}

data "aws_vpc" "default" {
  #default = true
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# TAG NAME 으로 subnet 을 가져온다.
data "aws_subnets" "default" {
  #vpc_id = data.aws_vpc.default.id ## deprecated option
  filter {
    name = "tag:Name"
    values = ["${var.cluster_name}-sb-public-*"]
    # values = ["${var.cluster_name}-sb-private-*"]
  }
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create DB Subnet with private db subnet created with VPC
resource "aws_db_subnet_group" "example" {
  name        = "${var.cluster_name}-sb-db"
  description = "The subnets used for dayone RDS deployments"
  subnet_ids  = data.aws_subnets.default.ids

  tags = {
    Name = "${var.cluster_name}-sb-db"
  }
}

resource "aws_security_group" "db" {
  name = "${var.cluster_name}-sg-db"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = local.db_service_port
    to_port = local.db_service_port
    protocol = local.tcp_protocol
    cidr_blocks = [local.work_cidr, local.home_cidr]
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix = "${var.cluster_name}-" # identifier_prefix = "dy-tf-stage_"
  engine = "mysql"
  allocated_storage = 10
  instance_class = var.instance_type    # instance_class = "db.t2.micro"
  db_name = "dy_tf_ex_database"
  username = var.admin_username         # username = "admin"
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.example.name

  vpc_security_group_ids = ["${aws_security_group.db.id}"]

  # password = data.aws_secretsmanager_secret_version.db_password.secrete_string
  password = var.db_password  # gjeodud, 특수문자안됨
}

# AWS Secret Manager 에 보안값을 넣고 읽어들여서 사용한다.
# data "aws_secretsmanager_secret_version" "db_password" {
#   secret_id = "mysql-master-password-stage"
# }

# terraform {
#   backend "s3" {
#     bucket = var.db_remote_state_key # bucket = "dy-tf-state"
#     key = var.db_remote_state_key    # key = "modules/data-stores/mysql/terraform.tfstate"
#     region = "ap-northeast-2"

#     dynamodb_table = "dy-tf-locks"
#     encrypt = true
#   }
# }