variable "cluster_name" {
  description = "The name to use for all the cluster resources (e.g. dy-tf-stage)"
  type = string
}

variable "environment" {
  description = "dev stg prd"
  type = string
}

variable "vpc_id" {
  description = "vpc id"
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

variable "db_password" {
  description = "The password of the database. min length 8 character (e.g. gjeodud01)"
  type = string
}

