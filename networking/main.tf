# ----- networking/main.tf ----

data "aws_availability_zones" "available" {}


resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "az_list" {
  input = data.aws_availability_zones.available.names
  result_count = var.max_subnet
}

resource "aws_vpc" "demi_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "demi_vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "demi_public_subnet" {
  count = var.public_sn_count
  vpc_id = aws_vpc.demi_vpc.id
  cidr_block = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "demi_mtc_public_subent${count.index + 1}"
  }
}

resource "aws_subnet" "demi_private_subnet" {
  count = var.private_sn_count
  vpc_id = aws_vpc.demi_vpc.id
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = random_shuffle.az_list.result[count.index]
  tags = {
    Name = "demi_mtc_private_subnet_${count.index + 1}"
  }
}

resource "aws_route_table_association" "demi_public_assoc"{
  count = var.public_sn_count
  subnet_id = aws_subnet.demi_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.demi_public_rt.id
}

resource "aws_internet_gateway" "demi_internet_gateway" {
  vpc_id = aws_vpc.demi_vpc.id

  tags = {
    Name = "demi_igw"
  }  
}

resource "aws_route_table" "demi_public_rt" {
  vpc_id = aws_vpc.demi_vpc.id
  
  tags = {
    Name = "demi_public_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.demi_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demi_internet_gateway.id
}

resource "aws_default_route_table" "demi_private_rt" {
  default_route_table_id = aws_vpc.demi_vpc.default_route_table_id
  
  tags = {
    Name = "demi_private"
  }
}

