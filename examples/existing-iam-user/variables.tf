# variable "user_names" {
#   description = "Create IAM users with these names"
#   type = list(string)
#   default = ["neo", "trinity", "morpheus"]
# }

# page 191 example
variable "names" {
  description = "A list of names"
  type = list(string)
  default = ["neo", "trinity", "morpheus"]
}

# page 194
variable "hero_thousand_faces" {
  description = "map"
  type = map(string)
  default = {
    neo = "hero"
    trinity = "love interest"
    morpheus = "mentor"
  }
}