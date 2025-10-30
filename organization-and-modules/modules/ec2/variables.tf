# Terraform file: variables.tf for module ec2

variable "ami" {
    type        = string
    description = "AMI para las instancias"
}

variable "instance_type" {
    type        = string
    description = "Tipo de instancia"
}

variable "subnets" {
    type        = list(string)
    description = "Subnets donde se lanzarán las instancias"
}

variable "security_group_id" {
    type        = string
    description = "Security Group ID asignado a las instancias"
}

