# Terraform file: variables.tf for module alb

variable "subnets" {
    type        = list(string)
    description = "Subnets para el ALB"
}

variable "alb_sg_id" {
    type        = string
    description = "Security Group ID para el ALB"
}

variable "target_sg_id" {
    type        = string
    description = "Security Group ID de los targets"
}

variable "instances_ids" {
    type        = list(string)
    description = "IDs de las instancias EC2"
}

variable "vpc_id" {
    type        = string
    description = "VPC ID"
}
