# Terraform file: main.tf for module network

# ==========================================
# NETWORK MODULE - VPC & SUBNETS
# ==========================================

data "aws_vpc" "default" {
    count    = var.vpc_id == null ? 1 : 0
    default  = true
}

locals {
    vpc_id = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id
}

resource "aws_subnet" "public_a" {
    vpc_id                  = local.vpc_id
    cidr_block              = "172.31.48.0/20"
    availability_zone       = var.azs[0]
    map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
    vpc_id                  = local.vpc_id
    cidr_block              = "172.31.64.0/20"
    availability_zone       = var.azs[1]
    map_public_ip_on_launch = true
}

