output "db_server_instance_id" {
  value = aws_db_instance.this.id
}

output "db_server_instance_arn" {
  value = aws_db_instance.this.arn
}

output "db_server_instance_endpoint" {
  value = aws_db_instance.this.address
}