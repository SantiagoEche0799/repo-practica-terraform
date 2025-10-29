variable "instance_name" {
    description = "Name of ec2 instance"
    type = string
}

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

variable "db_user" {
    description = "username for database"
    type = string
    default = "demo_db_postgres"
}

variable "db_pass" {
    description = "password for database"
    type = string
    sensitive = true
}