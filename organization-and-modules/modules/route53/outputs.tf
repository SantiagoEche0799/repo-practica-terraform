# Terraform file: outputs.tf for module route53

output "zone_id" {
    description = "Zone ID del dominio"
    value       = aws_route53_zone.primary.zone_id
}

