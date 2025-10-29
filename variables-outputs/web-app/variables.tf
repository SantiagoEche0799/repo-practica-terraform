#General Variables

variable "region" {
    description = "Default region for provider"
    type = string
    default = "us-east-1"
}

# EC2 Variables

variable "ami" {
    description = "Amazon machine image to use for ec2 instances"
    type = string
    default = "ami-0bbdd8c17ed981ef9"
}

variable "instance_type" {
    description = "ec2 instance type"
    type = string
    default = "t3.micro"
}

# S3 Variables

variable "bucket_prefix" {
    description = "prefix of s3 bucket for app data"
    type = string
}

# Route53 Variables

variable "domain" {
    description = "Domain for website" 
    type = string
}

# RDS Variables

variable "db_name" {
    description = "Username for DB"
    type = string
}

variable "db_user" {
    description = "Username for DB"
    type = string
}

variable "db_pass" {
    description = "Password for DB"
    type = string
    sensitive = true
}

variable "rds_engine" {
    description = "The RDS Engine"
    type = string
    default = "postgres"
}

variable "rds_engine_version" {
    type = string
    default = "12"
}

variable "rds_instance_class" {
    type = string
    default = "db.t3.micro"
}

variable "rds_allocated_storage" {
    type = number
    default = 20
}

variable "rds_storage_type" {
    type = string
    default = "standard"
}

variable "rds_skip_final_snapshot" {
    type = bool
    default = true
}

# Networking: Subnets Variables

variable "public_subnet_a_cidr" {
    description = "CIDR block for public subnet A."
    type = string
    default = "172.31.48.0/20"
}

variable "public_subnet_b_cidr" {
    description = "CIDR block for public subnet B."
    type = string
    default = "172.31.64.0/20"
}

variable "availability_zones" {
    description = "List if availability zones to use"
    type = list(string)
    default = ["us-east-1a", "us-east-1b"]
}



