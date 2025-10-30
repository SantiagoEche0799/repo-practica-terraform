# Terraform file: variables.tf for module rds

variable "vpc_id" {
    type        = string
    description = "VPC ID donde se crea la DB"
}

variable "subnets" {
    type        = list(string)
    description = "Subnets para la DB"
}

variable "db_name" {
    type        = string
    description = "Nombre de la base de datos"
}

variable "db_user" {
    type        = string
    description = "Usuario de la DB"
    sensitive   = true
}

variable "db_pass" {
    type        = string
    description = "Contraseña de la DB"
    sensitive   = true
}

variable "instance_sg_id" {
    type        = string
    description = "Security Group ID para la DB"
}

