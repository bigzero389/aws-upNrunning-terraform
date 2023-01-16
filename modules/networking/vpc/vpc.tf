locals {
  system = "${var.cluster_name}-${var.environment}"
  creator = "${var.creator}"
  group = "${var.group}"

  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
  cidr_block = var.cidr_block
}

resource "aws_vpc" "this" {
  cidr_block = local.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.system}-vpc",
    creator= "${local.creator}",
    group = "${local.group}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
    Name = "${local.system}-igw",
    creator= "${local.creator}",
    group = "${local.group}"
  }
}

resource "aws_subnet" "public" {
  count      = "${length(local.public_subnets)}"
  cidr_block = "${element(values(local.public_subnets), count.index)}"
  vpc_id     = "${aws_vpc.this.id}"

  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(local.public_subnets), count.index)}"

  tags = {
    Name = "${local.system}-sb-public-${element(values(local.azs), count.index)}",
    creator= "${local.creator}",
    group = "${local.group}"
  }
}

resource "aws_subnet" "private" {
  count      = "${length(local.private_subnets)}"
  cidr_block = "${element(values(local.private_subnets), count.index)}"
  vpc_id     = "${aws_vpc.this.id}"

  map_public_ip_on_launch = true
  availability_zone       = "${element(keys(local.private_subnets), count.index)}"

  tags = {
    Name = "${local.system}-sb-private-${element(values(local.azs), count.index)}",
    creator= "${local.creator}",
    group = "${local.group}"
  }
}

resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.this.main_route_table_id}"

  tags = {
    Name = "${local.system}-public",
    creator= "${local.creator}",
    group = "${local.group}"
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
    Name = "${local.system}-private",
    creator= "${local.creator}",
    group = "${local.group}"
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
    Name = "${local.system}-eip",
    creator= "${local.creator}",
    group = "${local.group}"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.0.id}"

  tags = {
    Name = "${local.system}-nat-gw",
    creator= "${local.creator}",
    group = "${local.group}"
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