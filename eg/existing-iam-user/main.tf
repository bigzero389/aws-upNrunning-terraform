provider "aws" {
  region = "ap-northeast-2"
}

# 3 user create
# resource "aws_iam_user" "simple-loop" {
#   count = 3
#   name = "bigzero.${count.index}"
# }

# user by list
# resource "aws_iam_user" "sample-list" {
#   count = length(var.user_names)
#   name = var.user_names[count.index]
# }

# resource "aws_iam_user" "sample-collection" {
#   for_each = toset(var.user_names)
#   name = each.value  
# }