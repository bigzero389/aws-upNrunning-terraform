provider "aws" {
	region = "ap-northeast-2"
}

resource "aws_instance" "example" {
	ami = "ami-0eddbd81024d3fbdd"
	instance_type = "t3.micro"

  tags = {
    Name = "terraform-example-dyheo"
  }
}
	
