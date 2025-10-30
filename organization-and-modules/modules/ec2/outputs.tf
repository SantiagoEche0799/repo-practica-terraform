# Terraform file: outputs.tf for module ec2

output "instance_ids" {
    description = "IDs de las instancias EC2 creadas"
    value       = [aws_instance.instance_1.id, aws_instance.instance_2.id]
}

output "instance_public_ips" {
    description = "IPs públicas de las instancias EC2"
    value       = [aws_instance.instance_1.public_ip, aws_instance.instance_2.public_ip]
}

