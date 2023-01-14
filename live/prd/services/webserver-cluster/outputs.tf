# output "public_ip" {
#   # value = "${join(",", aws_autoscaling_group.example.*.public_ip)}"
#   value = data.aws_instances.example.public_ips
#   description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balance"
}
