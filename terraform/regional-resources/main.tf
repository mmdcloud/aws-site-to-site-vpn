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

resource "aws_security_group" "vpc_sg" {
  name   = "${var.region_name}_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_key_pair" "key_pair" {
  key_name = "surajm"
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.key_pair.key_name
  subnet_id                   = aws_subnet.subnets[0].id
  security_groups             = [aws_security_group.vpc_sg.id]
  user_data                   = var.user_data
  tags = {
    Name = "${var.region_name}_instance"
  }
}
