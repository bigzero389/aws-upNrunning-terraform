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

  system_name = "${var.cluster_name}-${var.environment}"
}

# security group define
resource "aws_security_group" "instance" {
  name = "${local.system_name}-sg-instance"
  vpc_id = var.vpc_id
  # vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "service_in" {
  type = "ingress"
  from_port = var.server_port
  to_port = var.server_port
  protocol = "tcp"
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "service_out" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = local.any_protocol
  cidr_blocks = local.all_ips
  security_group_id = aws_security_group.instance.id
}

resource "aws_security_group_rule" "ssh" {
  type = "ingress"

  from_port = local.ssh_port
  to_port = local.ssh_port
  protocol = local.tcp_protocol
  cidr_blocks = [local.work_cidr, local.home_cidr] 

  security_group_id = aws_security_group.instance.id
}

data "aws_instances" "example" {
  filter {
    name = "tag:Name"
    values = ["${local.system_name}-asg-ex"]
  }
}

# ASG setting
resource "aws_launch_configuration" "example" {
  name = "${local.system_name}-launch-config"

  image_id  = var.ami
	instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data = var.user_data
  # key_name = "dy-cloud-dev.pem"
  key_name = var.key_pair
 
  lifecycle {
    create_before_destroy = true
  }
}

# auto scaling group define
resource "aws_autoscaling_group" "example" {
  # 명시적으로 시작구성이름과 클러스터이름에 의존하여 설정된다.
  name = "${local.system_name}-${aws_launch_configuration.example.name}"

  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_check_type

  min_size = var.min_size
  max_size = var.max_size

  # ASG 배포완료 전 최소한 이 인스턴스가 상태확인을 통과할 때까지 기다린다.
  min_elb_capacity = var.min_size

  tag {
    key = "Name"
    value = "${local.system_name}-asg-ex"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 5
  recurrence = "0 9 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"

  autoscaling_group_name = aws_autoscaling_group.example.name
}

# cloudwatch read only
data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

# cloudwatch full access
resource "aws_iam_policy" "cloudwatch_full_access" {
  count = var.give_user_cloudwatch_full_access ? 1 : 0

  name = "${local.system_name}-cloudwatch-full-access"
  policy = data.aws_iam_policy_document.cloudwatch_full_access.json
}

data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect = "Allow"
    actions = ["cloudwatch:*"]
    resources = ["*"]
  }
}

# cloudwatch readonly access
resource "aws_iam_policy" "cloudwatch_read_only" {
  count = var.give_user_cloudwatch_full_access ? 0 : 1
  
  name = "${local.system_name}-cloudwatch-read-only"
  policy = data.aws_iam_policy_document.cloudwatch_read_only.json
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name = "${local.system_name}-high-cpu-utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  period = 300 # second, 5 min
  statistic = "Average"
  threshold = 90 
  unit = "Percent"
}

## cloudwatch metric alarm
resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0  # instance type 이 t 시리즈들만 CPU credit 이 있기 때문에 필터링함.

  alarm_name = "${local.system_name}-low-cpu-credit-balance"
  namespace = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  period = 300 # second, 5 min
  statistic = "Minimum"
  threshold = 10 
  unit = "Count" 
}

# db 관련 정보 불러오기 데이터소스.
data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket #bucket = "dy-tf-state"
    key = var.db_remote_state_key       #key = "stg/data-stores/mysql/terraform.tfstate"
    region = "ap-northeast-2"
  }
}