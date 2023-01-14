variable "password" {
  description = "The password of the database. (e.g. gjeodud01)"
  type = string
  default = "gjeodud01"
}

variable "cluster_name" {
  description = "All my Project Name"
  type = string
  default = "dy-tf"
}

variable "environment" {
  description = "System Object (e.g. dev stg prd)"
  type = string
  default = "stg"
}

