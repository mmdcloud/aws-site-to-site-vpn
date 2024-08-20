# Customer Gateway
resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = module.mumbai-resources.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "customer_gateway"
  }
}

# VPC Gateway
resource "aws_vpn_gateway" "vpc_gw" {
  vpc_id = module.nv-resources.vpc_id

  tags = {
    Name = "vpc_gw"
  }
}

# VPC Gateway Attachment
resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = module.nv-resources.vpc_id
  vpn_gateway_id = aws_vpn_gateway.vpc_gw.id
}

# Site To Site VPN Connection
resource "aws_vpn_connection" "site_to_site_vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vpc_gw.id
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true
}

# Route Propagation
resource "aws_vpn_gateway_route_propagation" "route_propagation" {
  vpn_gateway_id = aws_vpn_gateway.vpc_gw.id
  route_table_id = module.nv-resources.route_table_id
}
