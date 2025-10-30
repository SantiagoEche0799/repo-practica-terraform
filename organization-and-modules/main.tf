# ============================================================
# ROOT MODULE - Carga los módulos de infraestructura
# ============================================================

# ------------------------------
# NETWORK MODULE
# ------------------------------
module "network" {
    source  = "./modules/network"
    region  = var.region
    vpc_id  = var.vpc_id
    azs     = var.availability_zones
}

# ------------------------------
# SECURITY MODULE
# ------------------------------
module "security" {
    source  = "./modules/security/"
    vpc_id  = module.network.vpc_id
}

# ------------------------------
# EC2 MODULE
# ------------------------------
module "ec2" {
    source        = "./modules/ec2/"
    ami           = var.ami
    instance_type = var.instance_type
    subnets       = module.network.public_subnets
    security_group_id = module.security.instance_sg_id
}

# ------------------------------
# ALB MODULE
# ------------------------------
module "alb" {
    source         = "./modules/alb/"
    subnets        = module.network.public_subnets
    alb_sg_id      = module.security.alb_sg_id
    target_sg_id   = module.security.instance_sg_id
    instances_ids  = module.ec2.instance_ids
    vpc_id         = module.network.vpc_id
}

# ------------------------------
# S3 MODULE
# ------------------------------
module "s3" {
    source        = "./modules/s3/"
    bucket_prefix = var.bucket_prefix
}

# ------------------------------
# ROUTE53 MODULE
# ------------------------------
module "route53" {
    source       = "./modules/route53/"
    domain       = var.domain
    alb_dns_name = module.alb.alb_dns_name
    alb_zone_id  = module.alb.alb_zone_id
    }

# ------------------------------
# RDS MODULE
# ------------------------------
module "rds" {
    source              = "./modules/rds/"
    vpc_id              = module.network.vpc_id
    subnets             = module.network.public_subnets
    db_name             = var.db_name
    db_user             = var.db_user
    db_pass             = var.db_pass
    instance_sg_id      = module.security.instance_sg_id
}
