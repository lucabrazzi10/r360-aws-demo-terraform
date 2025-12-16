

output "primary_endpoint" {
  value       = aws_db_instance.postgres_primary.endpoint
  description = "Write endpoint for the app (Primary)"
}

output "replica_endpoint" {
  value       = aws_db_instance.postgres_read_replica.endpoint
  description = "Read / DR endpoint (Replica)"
}
output "db_sg_id" {
  value = aws_security_group.db_sg.id
}

output "db_port" {
  value = aws_db_instance.postgres_primary.port
}
