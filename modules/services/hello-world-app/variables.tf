variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  # default = 8080
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run (e.g. t2.micro)"
  type = string
}

variable "key_pair" {
  description = "The EC2 key pair(e.g. dy-tf-dev)"
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

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type = map(string)
  default = {}
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "give_user_cloudwatch_full_access" {
  description = "If true, user get full access to CloudWatch"
  type = bool
}

variable "enable_new_user_data" {
  description = "If set to true, use the new User Data script"
  type = bool
}

variable "db_remote_state_bucket" {
  description = "The name of the s3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database'sremote state in s3"
  type = string
}

variable "environment" {
  description = "The name of the environment we're deploying to"
  type = string
}