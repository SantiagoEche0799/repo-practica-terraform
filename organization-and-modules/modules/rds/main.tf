# Terraform file: main.tf for module rds

resource "aws_db_subnet_group" "db_subnets" {
    name       = "db-subnet-group"
    subnet_ids = var.subnets
}

resource "aws_db_instance" "db" {
    allocated_storage         = 20
    auto_minor_version_upgrade = true
    storage_type              = "standard"
    engine                    = "postgres"
    engine_version            = "12"
    instance_class            = "db.t3.micro"
    db_name                   = var.db_name
    username                  = var.db_user
    password                  = var.db_pass
    skip_final_snapshot       = true
    db_subnet_group_name      = aws_db_subnet_group.db_subnets.name
    vpc_security_group_ids    = [var.instance_sg_id]
}

