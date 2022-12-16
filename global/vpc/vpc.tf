# AWS용 프로바이더 구성
provider "aws" {
  profile = "default"
  region = "ap-northeast-2"
}

## 예제에서는 서울리전 만 지정한다.
variable "region" {
  default = "ap-northeast-2"
}

locals {
  ## 신규 VPC 를 구성하는 경우 Service 과 pem_file 를 새로 넣어야 한다.
  Service = "dy-tf"
  Creator = "dyheo"
  Group = "cloudteam"

  #pem_file = "dyheo-histech"

  ## 신규 구축하는 시스템의 cidr 를 지정한다. 
  public_subnets = {
    "${var.region}a" = "10.77.101.0/24"
#    "${var.region}b" = "10.66.102.0/24"
    "${var.region}c" = "10.77.103.0/24"
  }
  private_subnets = {
#    "${var.region}a" = "10.77.111.0/24"
#    "${var.region}b" = "10.66.112.0/24"
    "${var.region}c" = "10.77.113.0/24"
  }
  azs = {
    "${var.region}a" = "a"
#    "${var.region}b" = "b"
    "${var.region}c" = "c"
  }
}

resource "aws_vpc" "this" {
  ## cidr 를 지정해야 한다.
  cidr_block = "10.77.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.Service}-vpc",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${local.Service}-igw",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_subnet" "public" {
  count      = "${length(local.public_subnets)}"
  cidr_block = "${element(values(local.public_subnets), count.index)}"
  vpc_id     = "${aws_vpc.this.id}"

  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(local.public_subnets), count.index)}"

  tags = {
    Name = "${local.Service}-sb-public-${element(values(local.azs), count.index)}",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_subnet" "private" {
  count      = "${length(local.private_subnets)}"
  cidr_block = "${element(values(local.private_subnets), count.index)}"
  vpc_id     = "${aws_vpc.this.id}"

  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(local.private_subnets), count.index)}"

  tags = {
    Name = "${local.Service}-sb-private-${element(values(local.azs), count.index)}",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.this.main_route_table_id}"

  tags = {
    Name = "${local.Service}-public",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = "${length(local.public_subnets)}"
  route_table_id         = "${aws_default_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(local.public_subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_default_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${local.Service}-private",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(local.private_subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${local.Service}-eip",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.0.id}"

  tags = {
    Name = "${local.Service}-nat-gw",
    Creator= "${local.Creator}",
    Group = "${local.Group}"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

output "aws_vpc" {
  value = aws_vpc.this.id
}

terraform {
  backend "s3" {
    bucket = "dy-tf-state"
    key = "global/vpc/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "dy-tf-locks"
    encrypt = true
  }
}
