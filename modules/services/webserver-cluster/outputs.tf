output "public_ip" {
  # value = "${join(",", aws_autoscaling_group.example.*.public_ip)}"
  value = data.aws_instances.example.public_ips
  description = "The public IP address of the web server"
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name 
  description = "The domain name of the load balance"
}

output "asg_name" {
  value = aws_autoscaling_group.example.name
  description = "The name of the Auto Scaling Group"
}

