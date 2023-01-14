# locals {
#   ssh_port = 22
#   http_port = 80
#   any_port = 0
#   any_protocol = "-1"
#   tcp_protocol = "tcp"
#   http_protocol = "HTTP"
#   https_protocol = "HTTPS"
#   all_ips = ["0.0.0.0/0"]
#   home_cidr = "125.177.68.23/32"
#   work_cidr = "211.206.114.80/32"
# }

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
  }
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = module.alb.alb_http_listener_arn
  # listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  # name = "${var.cluster_name}-asg"
  name = "${var.cluster_name}-${var.environment}-tg"
  port = var.server_port
  protocol = local.http_protocol
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 30
    timeout = 30
    healthy_threshold = 2
    unhealthy_threshold = 10
  }
}

# server port 및 db 관련 정보 쉘 파일로 전달.
data "template_file" "user_data" {
  count = var.enable_new_user_data ? 0 : 1
  template = file("${path.module}/user-data.sh")

  vars = {
    server_port = var.server_port # 8080
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  }
}

# data "template_file" "user_data_new" {
#   count = var.enable_new_user_data ? 1 : 0
#   template = file("${path.module}/user-data-new.sh")

#   vars = {
#     server_port = var.server_port # 8080
#   }
# }

module "asg" {
  source = "../../cluster/asg-rolling-deploy"

  cluster_name = "${var.cluster_name}-${var.environment}-asg"
  ami = var.ami
  user_data = var.user_data
  instance_type = var.instance_type

  min_size = var.min_size
  max_size = var.max_size
  enable_autoscaling = var.enable_autoscaling

  subnet_ids = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  custom_tags = var.custom_tags
}

module "alb" {
  source = "../../networking/alb"

  alb_name = "${var.cluster_name}-${var.environment}-alb"
  subnet_ids = data.aws_subnet_ids.default.ids
}