# Terraform file: outputs.tf for module security

output "alb_sg_id" {
    description = "Security Group ID del ALB"
    value       = aws_security_group.alb.id
}

output "instance_sg_id" {
    description = "Security Group ID de las instancias EC2"
    value       = aws_security_group.instances.id
}

