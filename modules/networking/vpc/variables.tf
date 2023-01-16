variable "region" {
  description = "Set AWS Region"
  type = string
}

variable "cluster_name" {
  description = "Project cluster name"
  type = string
}

variable "environment" {
  description = "Project environment (e.g. dev stg prd)"
  type = string
}

variable "creator" {
  description = "Set creator identify or name, e.g. dyheo"
  type = string
}

variable "group" {
  description = "Set creator's group, e.g. cloudteam"
  type = string
}

variable "azs" {
  description = "Multi-AZ to use in seoul, e.g. \"1\" = \"a\" \\n \"2\" = \"c\" "
  type = map
}

variable "public_subnets" {
  type = map
}

variable "private_subnets" {
  type = map
}

variable "cidr_block" {
  type = string
}