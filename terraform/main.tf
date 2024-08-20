# NV VPC
resource "aws_vpc" "nv_vpc" {
  cidr_block           = "10.1.0.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "nv_vpc"
  }
}

resource "aws_subnet" "nv_subnets" {
  count             = length(var.nv_subnets)
  vpc_id            = aws_vpc.nv_vpc.id
  cidr_block        = element(var.nv_subnets, count.index)
  availability_zone = element(var.nv_azs, count.index)
  tags = {
    Name = "nv_subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "nv_igw" {
  vpc_id = aws_vpc.nv_vpc.id
  tags = {
    Name = "nv_igw"
  }
}

resource "aws_route_table" "nv_route_table" {
  vpc_id = aws_vpc.nv_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nv_igw.id
  }
  tags = {
    Name = "nv_route_table"
  }
}

resource "aws_route_table_association" "nv_route_table_association" {
  count          = length(var.nv_subnets)
  subnet_id      = element(aws_subnet.nv_subnets[*].id, count.index)
  route_table_id = aws_route_table.nv_route_table.id
}

# Mumbai VPC
resource "aws_vpc" "mumbai_vpc" {
  cidr_block           = "10.2.0.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "mumbai_vpc"
  }
}

resource "aws_subnet" "mumbai_subnets" {
  count             = length(var.mumbai_subnets)
  vpc_id            = aws_vpc.mumbai_vpc.id
  cidr_block        = element(var.mumbai_subnets, count.index)
  availability_zone = element(var.mumbai_azs, count.index)
  tags = {
    Name = "mumbai_subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "mumbai_igw" {
  vpc_id = aws_vpc.mumbai_vpc.id
  tags = {
    Name = "mumbai_igw"
  }
}

resource "aws_route_table" "mumbai_route_table" {
  vpc_id = aws_vpc.mumbai_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai_igw.id
  }
  tags = {
    Name = "mumbai_route_table"
  }
}

resource "aws_route_table_association" "mumbai_route_table_association" {
  count          = length(var.mumbai_subnets)
  subnet_id      = element(aws_subnet.mumbai_subnets[*].id, count.index)
  route_table_id = aws_route_table.mumbai_route_table.id
}
