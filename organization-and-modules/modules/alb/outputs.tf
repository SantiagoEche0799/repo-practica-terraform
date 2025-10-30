# Terraform file: outputs.tf for module alb

output "alb_dns_name" {
    description = "DNS del Load Balancer"
    value       = aws_lb.load_balancer.dns_name
}

output "alb_zone_id" {
    description = "Zone ID del Load Balancer"
    value       = aws_lb.load_balancer.zone_id
}

