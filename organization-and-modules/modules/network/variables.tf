# Terraform file: variables.tf for module network

variable "region" {
    description = "Región de AWS"
    type        = string
}

variable "vpc_id" {
    description = "VPC ID (opcional, si no se especifica usa la VPC default)"
    type        = string
    default     = null
}

variable "azs" {
    description = "Zonas de disponibilidad a usar"
    type        = list(string)
}

