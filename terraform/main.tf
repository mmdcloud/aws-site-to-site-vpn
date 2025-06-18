# module "nv-resources" {
#   source      = "./regional-resources"
#   azs         = var.nv_azs
#   region_name = "nv"
#   cidr        = "10.1.0.0/24"
#   subnets     = var.nv_subnets
#   key_pair    = "madmaxkeypair"
#   user_data   = filebase64("${path.module}/../scripts/nv_user_data.sh")
#   providers = {
#     aws = aws.nv
#   }
# }

# module "mumbai-resources" {
#   source      = "./regional-resources"
#   azs         = var.mumbai_azs
#   region_name = "mumbai"
#   cidr        = "10.2.0.0/24"
#   key_pair    = "mumbai_keypair"
#   user_data   = filebase64("${path.module}/../scripts/mumbai_user_data.sh")
#   subnets     = var.mumbai_subnets
#   providers = {
#     aws = aws.mumbai
#   }
# }

# # Customer Gateway
# resource "aws_customer_gateway" "customer_gateway" {
#   bgp_asn    = 65000
#   ip_address = module.mumbai-resources.public_ip
#   type       = "ipsec.1"

#   tags = {
#     Name = "customer_gateway"
#   }
# }

# # VPC Gateway
# resource "aws_vpn_gateway" "vpc_gw" {
#   vpc_id = module.nv-resources.vpc_id

#   tags = {
#     Name = "vpc_gw"
#   }
# }

# # VPC Gateway Attachment
# resource "aws_vpn_gateway_attachment" "vpn_attachment" {
#   vpc_id         = module.nv-resources.vpc_id
#   vpn_gateway_id = aws_vpn_gateway.vpc_gw.id
# }

# # Site To Site VPN Connection
# resource "aws_vpn_connection" "site_to_site_vpn" {
#   vpn_gateway_id      = aws_vpn_gateway.vpc_gw.id
#   customer_gateway_id = aws_customer_gateway.customer_gateway.id
#   type                = "ipsec.1"
#   static_routes_only  = true
# }

# # Route Propagation
# resource "aws_vpn_gateway_route_propagation" "route_propagation" {
#   vpn_gateway_id = aws_vpn_gateway.vpc_gw.id
#   route_table_id = module.nv-resources.route_table_id
# }

# Create VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC1"
  }
}

# Create VPC 2
resource "aws_vpc" "vpc2" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC2"
  }
}

# Create Internet Gateway for VPC1
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "IGW-VPC1"
  }
}

# Create Internet Gateway for VPC2
resource "aws_internet_gateway" "igw2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "IGW-VPC2"
  }
}

# Create Subnet in VPC1
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Subnet-VPC1"
  }
}

# Create Subnet in VPC2
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Subnet-VPC2"
  }
}

# Create Route Table for VPC1
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  route {
    cidr_block = aws_vpc.vpc2.cidr_block
    gateway_id = aws_vpn_connection.vpn1.vpn_gateway_id
  }

  tags = {
    Name = "RouteTable-VPC1"
  }
}

# Create Route Table for VPC2
resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw2.id
  }

  route {
    cidr_block = aws_vpc.vpc1.cidr_block
    gateway_id = aws_vpn_connection.vpn2.vpn_gateway_id
  }

  tags = {
    Name = "RouteTable-VPC2"
  }
}

# Associate Route Table with Subnet1
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt1.id
}

# Associate Route Table with Subnet2
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt2.id
}

# Create Security Group for VPC1
resource "aws_security_group" "sg1" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH and ICMP traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-VPC1"
  }
}

# Create Security Group for VPC2
resource "aws_security_group" "sg2" {
  name        = "allow_ssh_icmp"
  description = "Allow SSH and ICMP traffic"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-VPC2"
  }
}

# Create Customer Gateway for VPC1
resource "aws_customer_gateway" "cgw1" {
  bgp_asn    = 65000
  ip_address = aws_instance.vm2.public_ip
  type       = "ipsec.1"
  tags = {
    Name = "CGW-VPC1"
  }
}

# Create Customer Gateway for VPC2
resource "aws_customer_gateway" "cgw2" {
  bgp_asn    = 65000
  ip_address = aws_instance.vm1.public_ip
  type       = "ipsec.1"
  tags = {
    Name = "CGW-VPC2"
  }
}

# Create VPN Gateway for VPC1
resource "aws_vpn_gateway" "vgw1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "VGW-VPC1"
  }
}

# Create VPN Gateway for VPC2
resource "aws_vpn_gateway" "vgw2" {
  vpc_id = aws_vpc.vpc2.id
  tags = {
    Name = "VGW-VPC2"
  }
}

# Create VPN Connection from VPC1 to VPC2
resource "aws_vpn_connection" "vpn1" {
  vpn_gateway_id      = aws_vpn_gateway.vgw1.id
  customer_gateway_id = aws_customer_gateway.cgw1.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "VPN-VPC1-to-VPC2"
  }
}

# Create VPN Connection from VPC2 to VPC1
resource "aws_vpn_connection" "vpn2" {
  vpn_gateway_id      = aws_vpn_gateway.vgw2.id
  customer_gateway_id = aws_customer_gateway.cgw2.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "VPN-VPC2-to-VPC1"
  }
}

resource "aws_vpn_gateway_attachment" "vpc1_attachment" {
  vpc_id         = aws_vpc.vpc1.id
  vpn_gateway_id = aws_vpn_gateway.vgw1.id
}

resource "aws_vpn_gateway_attachment" "vpc2_attachment" {
  vpc_id         = aws_vpc.vpc2.id
  vpn_gateway_id = aws_vpn_gateway.vgw2.id
}

resource "aws_vpn_gateway_route_propagation" "vpc1_propagation" {
  vpn_gateway_id = aws_vpn_gateway.vgw1.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_vpn_gateway_route_propagation" "vpc2_propagation" {
  vpn_gateway_id = aws_vpn_gateway.vgw2.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_vpn_connection_route" "vpc1_route" {
  destination_cidr_block = aws_vpc.vpc2.cidr_block
  vpn_connection_id      = aws_vpn_connection.vpn1.id
}

resource "aws_vpn_connection_route" "vpc2_route" {
  destination_cidr_block = aws_vpc.vpc1.cidr_block
  vpn_connection_id      = aws_vpn_connection.vpn2.id
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
  key_name = "madmaxkeypair"
}

# Create EC2 Instance in VPC1
resource "aws_instance" "vm1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet1.id
  vpc_security_group_ids      = [aws_security_group.sg1.id]
  associate_public_ip_address = true
  key_name                    = "madmaxkeypair"
  user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "Hello from VM1 in VPC1" | sudo tee /var/www/html/index.html
  EOF
  tags = {
    Name = "VM1"
  }
}

# Create EC2 Instance in VPC2
resource "aws_instance" "vm2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet2.id
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  associate_public_ip_address = true
  key_name                    = "madmaxkeypair"
  user_data                   = <<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "Hello from VM2 in VPC2" | sudo tee /var/www/html/index.html
  EOF
  tags = {
    Name = "VM2"
  }
}