# Terraform file: variables.tf for module route53

variable "domain" {
    type        = string
    description = "Nombre del dominio"
}

variable "alb_dns_name" {
    type        = string
    description = "DNS del ALB"
}

variable "alb_zone_id" {
    type        = string
    description = "Zone ID del ALB"
}

