resource "aws_instance" "example" {
  ami = "ami-06eea3cd85e2db8ce"
  instance_type = "t2.micro"

  tags = {
    Name = "dy-tf-instance-workspace"
  }
}

terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "workspace-example/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}
