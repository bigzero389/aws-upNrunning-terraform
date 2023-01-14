# output "neo_arn" {
#   value = aws_iam_user.sample-loop[0].arn
#   description = "The ARN for user Neo"
# }

# output "all_arns" {
#   value = aws_iam_user.sample-list[*].arn 
#   description = "The ARNs for all users"
# }

# output "all_users" {
#   value = aws_iam_user.sample-collection
# }

# output "all_arns" {
#   value = values(aws_iam_user.sample-collection)[*].arn
# }

# page 193
# output "upper_names" {
#   # value = [for name in var.names : upper(name)]
#   value = [for name in var.names : upper(name) if length(name) < 5]
# }

# page 194
output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}
# page 195
output "upper_roles" {
  value = { for name, role in var.hero_thousand_faces : upper(name) => upper(role) }
}
# page 196
output "for_directive_n_strip" {
  value = <<EOF
  %{~ for name in var.names ~}  # 인덴트 삭제인듯
    ${name}
  %{~ endfor ~} # 뒤에 공백인듯
  EOF
}