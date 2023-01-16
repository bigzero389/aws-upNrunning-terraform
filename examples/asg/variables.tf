variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
  default = "dy-tf"
}

variable "environment" {
  description = "project object (e.g. dev stg prd)"
  type = string
  default = "stg"
}

