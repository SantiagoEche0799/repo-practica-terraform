# Terraform file: outputs.tf for module rds

output "db_endpoint" {
    description = "Endpoint de la base de datos RDS"
    value       = aws_db_instance.db.endpoint
}

