variable "vpc_id" {
  description = "vpc id"
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "environment" {
  description = "project object (e.g. dev stg prd)"
  type = string
}

variable "ami" {
  description = "The name to use for AMI"
  type = string
  default = "ami-06eea3cd85e2db8ce"
}

variable "instance_type" {
  description = "The type of EC2 instances to run (e.g. t2.micro)"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 instance in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 instance in the ASG"
  type = number
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type = map(string)
  default = {}
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type = list(string)
}

variable "target_group_arns" {
  description = "The ARNs of ELB target groups in which to register Instances"
  type = list(string)
  default = []
}

variable "health_check_type" {
  description = "The type of health check to perform. Musto be one of: EC2, ELB"
  type = string
  default = "EC2"
}

variable "user_data" {
  description = "The User Data script to run in each Instance at boot"
  type = string
  default = null
}

variable "key_pair" {
  description = "bigzero's ec2 key pair name for study"
  type = string
  default = "dy-cloud-dev"
}

variable "give_user_cloudwatch_full_access" {
  description = "If true, user get full access to CloudWatch"
  type = bool
}

# variable "enable_new_user_data" {
#   description = "If set to true, use the new User Data script"
#   type = bool
# }

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database'sremote state in s3"
  type = string
}