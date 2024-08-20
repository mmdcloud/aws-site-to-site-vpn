output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "route_table_id" {
  value = aws_route_table.route_table.id
}

output "public_ip" {
  value = aws_instance.instance.public_ip
}
