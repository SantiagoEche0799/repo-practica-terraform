output "alb_dns_name" {
    description = "DNS del Application Load Balancer"
    value       = module.alb.alb_dns_name
}

output "s3_bucket_name" {
    description = "Nombre del bucket S3"
    value       = module.s3.bucket_name
}

output "rds_endpoint" {
    description = "Endpoint de la base de datos RDS"
    value       = module.rds.db_endpoint
}

output "instance_ips" {
    description = "Direcciones IP de las instancias EC2"
    value       = module.ec2.instance_public_ips
}
