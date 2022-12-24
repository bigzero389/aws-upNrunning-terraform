# TAG NAME 으로 subnet 을 가져온다.
data "aws_subnets" "default" {
  #vpc_id = data.aws_vpc.default.id ## deprecated option
  filter {
    name = "tag:Name"
    values = ["dy-tf-sb-public-*"]
  }
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group_rule" "service_in" {
  type = "ingress"
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "service_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group" "instance" {
  name = "dy-tf-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["211.206.114.80/32"]
  }
}

data "aws_instances" "example" {
  filter {
    name = "tag:Name"
    values = ["dy-tf-asg-ex"]
  }
}

# ASG setting
resource "aws_launch_configuration" "example" {
  name = "dy-tf-launch-config"
  image_id  = "ami-06eea3cd85e2db8ce"
  security_groups = [aws_security_group.instance.id]
  #key_name = "dy-cloud-dev.pem"
  key_name = "dy-cloud-dev"
	instance_type = "t2.micro"
 

  # user_data = <<-EOF
  #             #!/bin/bash
  #             echo "Hello, World" > index.html
  #             nohup busybox httpd -f -p ${var.server_port} &
  #             EOF
  # template file 을 읽어들인 렌더링 결과를 input 으로 받음.
  user_data = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name = "dy-tf-asg"
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "dy-tf-asg-ex"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  #default = true
  tags = {
    Name = "dy-tf-vpc"
  }
}

/* default 가 아니라 위에것으로 대체
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
*/


# ALB setting
resource "aws_lb" "example" {
  name = "dy-tf-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids

  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

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

resource "aws_security_group" "alb" {
  name = "dy-tf-alb"

  vpc_id = data.aws_vpc.default.id

  # permission traffic
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name = "dy-tf-asg"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
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

# db 관련 정보 불러오기 데이터소스.
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "dy-tf-state"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

# db 관련 정보 쉘 파일로 전달.
data "template_file" "user_data" {
  template = file("user-data.sh")

  vars = {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  }
}

# terraform 백엔드 구성
terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "modules/services/webserver-cluster/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}
