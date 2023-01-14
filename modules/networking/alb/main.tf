locals {
  ssh_port = 22
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  http_protocol = "HTTP"
  https_protocol = "HTTPS"
  all_ips = ["0.0.0.0/0"]
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
  }
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ALB setting
resource "aws_lb" "example" {
  # name = "${var.cluster_name}-lb"
  name = var.alb_name
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids

  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = local.http_port
  protocol = local.http_protocol

  # default return is 404 page error 
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
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
  name = "${var.cluster_name}-asg"
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

resource "aws_security_group" "alb" {
  vpc_id = data.aws_vpc.default.id
  name = "${var.cluster_name}-alb" # name = "dy-tf-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"

  from_port = local.http_port
  to_port = local.http_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "allow_http_outbound" {
  type = "egress"

  from_port = 0
  to_port = 0
  protocol = local.any_protocol
  cidr_blocks = local.all_ips

  security_group_id = aws_security_group.alb.id
}
