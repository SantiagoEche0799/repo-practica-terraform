# Terraform file: main.tf for module route53

resource "aws_route53_zone" "primary" {
    name = var.domain
}

resource "aws_route53_record" "root" {
    zone_id = aws_route53_zone.primary.zone_id
    name    = var.domain
    type    = "A"

    alias {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
    }
}

