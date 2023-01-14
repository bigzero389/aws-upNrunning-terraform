# output "public_ip" {
#   # value = "${join(",", aws_autoscaling_group.example.*.public_ip)}"
#   value = data.aws_instances.example.public_ips
#   description = "The public IP address of the web server"
# }

output "alb_dns_name" {
  value = module.alb.aws_lb.example.dns_name 
  description = "The domain name of the load balance"
}

output "asg_name" {
  value = module.asg.asg_name
  description = "The name of the Auto Scaling Group"
}

output "instance_security_group_id" {
  value = module.asg.instance_security_group_id
  description = "The ID of the Security Group attached to the load balance"
}

