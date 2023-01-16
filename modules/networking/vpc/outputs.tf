output "aws_vpc_id" {
  value = aws_vpc.this.id
}

output "aws_public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "aws_private_subnet_id" {
  value = aws_subnet.private.*.id
}