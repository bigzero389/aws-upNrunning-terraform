output "aws_vpc_id" {
  value = aws_vpc.this.id
}

output "aws_vpc_tags_all" {
  value = aws_vpc.this.tags_all
  # value = "${lookup(aws_vpc.this.tags[0], "Name")}"
}

output "aws_public_subnet_id" {
  value = aws_subnet.public.*.id
}

output "aws_private_subnet_id" {
  value = aws_subnet.private.*.id
}