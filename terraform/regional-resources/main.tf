resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.region_name}_vpc"
  }
}

resource "aws_subnet" "subnets" {
  count             = length(var.subnets)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.subnets, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "${var.region_name}_subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.region_name}_igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.region_name}_route_table"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(var.subnets)
  subnet_id      = element(aws_subnet.subnets[*].id, count.index)
  route_table_id = aws_route_table.route_table.id
}
