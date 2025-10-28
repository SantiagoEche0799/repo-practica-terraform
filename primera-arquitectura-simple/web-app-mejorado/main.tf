terraform {
  backend "s3" {
    bucket         = "devops-directive-remote-tf-state"
    key            = "primera-arquitectura-simple/web-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

################################
# Variables
################################
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_ami" {
  type    = string
  default = "ami-0bbdd8c17ed981ef9"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "db_username" {
  type    = string
  default = "demo_db_postgres"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "environment" {
  type    = string
  default = "dev"
}

################################
# Data sources
################################

data "aws_vpc" "default_vpc" {
  default = true
}

# Get all subnets in the default VPC. If you want only specific subnets
# filter by tag or availability zone. Many default subnets don't have tags,
# so the simplest approach is to filter only by vpc-id.
data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

################################
# S3 bucket (storage) - good to keep separate state and data
################################
resource "aws_s3_bucket" "bucket" {
  bucket_prefix  = "devops-directive-web-app-data"
  force_destroy  = true
  tags = {
    Environment = var.environment
    Project     = "web-app"
  }
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

################################
# Security groups
################################

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Allow HTTP to ALB"
  vpc_id      = data.aws_vpc.default_vpc.id
  tags = {
    Environment = var.environment
    Project     = "web-app"
  }
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for EC2 instances
resource "aws_security_group" "instances" {
  name        = "instance-security-group"
  description = "Security group for web instances - only allow traffic from ALB"
  vpc_id      = data.aws_vpc.default_vpc.id
  tags = {
    Environment = var.environment
    Project     = "web-app"
  }
}

# Allow inbound from ALB SG to instances on port 8080
resource "aws_security_group_rule" "allow_http_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.instances.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

# Allow instances to reach internet (for updates, etc.) - egress
resource "aws_security_group_rule" "instances_egress" {
  type              = "egress"
  security_group_id = aws_security_group.instances.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

################################
# EC2 instances
################################
resource "aws_instance" "instance_1" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default_subnet.ids[0]
  vpc_security_group_ids = [aws_security_group.instances.id]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, world 1" > /home/ec2-user/index.html
    python3 -m http.server 8080 &
    EOF
  tags = {
    Name        = "web-instance-1"
    Environment = var.environment
    Project     = "web-app"
  }
}

resource "aws_instance" "instance_2" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default_subnet.ids[1]
  vpc_security_group_ids = [aws_security_group.instances.id]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, world 2" > /home/ec2-user/index.html
    python3 -m http.server 8080 &
    EOF
  tags = {
    Name        = "web-instance-2"
    Environment = var.environment
    Project     = "web-app"
  }
}

################################
# Load Balancer + Target Group + Listener
################################
resource "aws_lb" "load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default_subnet.ids
  security_groups    = [aws_security_group.alb.id]
  tags = {
    Environment = var.environment
    Project     = "web-app"
  }
}

resource "aws_lb_target_group" "instances" {
  name     = "example-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.instances.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}

################################
# Route53 (create zone or use existing - be careful)
################################
# If you already have the domain in Route53 use a data source instead of creating a new zone.
resource "aws_route53_zone" "primary" {
  name = "devopsdemodeployed.com"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "devopsdemodeployed.com"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

################################
# RDS (Postgres) - use variables and sensitive password
################################
resource "aws_db_instance" "db_demo_instance" {
  allocated_storage           = 20
  auto_minor_version_upgrade  = true
  storage_type                = "standard"
  engine                      = "postgres"
  engine_version              = "12"
  instance_class              = "db.t3.micro"
  db_name                     = "my_db_postgres"
  username                    = var.db_username
  password                    = var.db_password
  skip_final_snapshot         = true
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.instances.id]
  tags = {
    Environment = var.environment
    Project     = "web-app"
  }
}

################################
# Outputs
################################
output "alb_dns_name" {
  value = aws_lb.load_balancer.dns_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "rds_endpoint" {
  value = aws_db_instance.db_demo_instance.endpoint
  description = "Endpoint to connect to the RDS instance"
}
