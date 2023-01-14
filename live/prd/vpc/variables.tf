variable "cluster_name" {
  description = "Project cluster name"
  type = string
  default = "dy-tf"
}

variable "environment" {
  description = "Project environment (e.g. dev stg prd)"
  type = string
  default = "prd"
}
