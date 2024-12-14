output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public[*].id
}

output "strapi_server_subnets_ids" {
  value = aws_subnet.strapi_server[*].id
}

output "db_server_subnets_ids" {
  value = aws_subnet.db_server[*].id
}
output "strapi_server_sg_id" {
  value = aws_security_group.strapi_server_sg.id
}
output "db_server_sg_id" {
  value = aws_security_group.db_server_sg.id
}
