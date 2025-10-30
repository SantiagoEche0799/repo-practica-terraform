# Terraform file: outputs.tf for module network

output "vpc_id" {
    description = "ID de la VPC utilizada"
    value       = local.vpc_id
}

output "public_subnets" {
    description = "IDs de las subnets públicas"
    value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

