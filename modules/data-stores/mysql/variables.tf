variable "db_password" {
  description = "The password of the database. min length 8 character (e.g. gjeodud01)"
  type = string
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources (e.g. dy-tf-stage)"
  type = string
}

variable "environment" {
  description = "dev stg prd"
  type = string
}

variable "instance_type" {
  description = "The type of DB instances to run (e.g. db.t2.micro)"
  type = string
  # default = "db.t2.micro"
}

variable "admin_username" {
  description = "The type of DBA username (e.g. admin)"
  type = string
  # default = "admin"
}

# variable "db_remote_state_bucket" {
#   description = "The name of the s3 bucket for the database's remote state"
#   type = string
#   # default = "dy-tf-state"
# }

# variable "db_remote_state_key" {
#   description = "The path for the database'sremote state in s3"
#   type = string
#   # default = "modules/data-stores/mysql/terraform.tfstat"
# }
