variable "region" {
    description = "Región de AWS"
    type        = string
}

variable "vpc_id" {
    description = "ID de la VPC (por defecto la VPC default)"
    type        = string
    default     = null
}

variable "availability_zones" {
    description = "Zonas de disponibilidad a usar"
    type        = list(string)
}

variable "ami" {
    description = "AMI usada por las instancias EC2"
    type        = string
}

variable "instance_type" {
    description = "Tipo de instancia EC2"
    type        = string
}

variable "bucket_prefix" {
    description = "Prefijo para el bucket S3"
    type        = string
}

variable "domain" {
    description = "Dominio Route53"
    type        = string
}

variable "db_name" {
    description = "Nombre de la base de datos RDS"
    type        = string
}

variable "db_user" {
    description = "Usuario de la base de datos RDS"
    type        = string
    sensitive   = true
}

variable "db_pass" {
    description = "Contraseña de la base de datos RDS"
    type        = string
    sensitive   = true
}
