terraform {
    backend "s3" {
        bucket         = "devops-directive-remote-tf-state"
        key            = "variables-outputs/web-app/terraform.tfstate"
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
    region = var.region
}

# ------------------------------
# NETWORKING: VPC y Subnets
# ------------------------------
data "aws_vpc" "default" {
    default = true
}

resource "aws_subnet" "public_a" {
    vpc_id                  = data.aws_vpc.default.id
    cidr_block              = var.public_subnet_a_cidr
    availability_zone       = var.availability_zones[0]
    map_public_ip_on_launch = true
        tags = {
        Name = "subnet-public-a"
    }
}

resource "aws_subnet" "public_b" {
    vpc_id                  = data.aws_vpc.default.id
    cidr_block              = var.public_subnet_b_cidr
    availability_zone       = var.availability_zones[1]
    map_public_ip_on_launch = true
        tags = {
        Name = "subnet-public-b"
    }
}

# ------------------------------
# SECURITY GROUPS
# ------------------------------
resource "aws_security_group" "alb" {
    name   = "alb-security-group"
    vpc_id = data.aws_vpc.default.id
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

resource "aws_security_group" "instances" {
    name   = "instance-security-group"
    vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type              = "ingress"
    security_group_id = aws_security_group.instances.id
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_instances_outbound" {
    type              = "egress"
    security_group_id = aws_security_group.instances.id
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
}

# ------------------------------
# INSTANCES
# ------------------------------
resource "aws_instance" "instance_1" {
    ami                    = var.ami
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.public_a.id
    vpc_security_group_ids = [aws_security_group.instances.id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 1" > index.html
        python3 -m http.server 8080 &
    EOF

    tags = {
        Name = "instance-1"
    }
}

resource "aws_instance" "instance_2" {
    ami                    = var.ami
    instance_type          = var.instance_type
    subnet_id              = aws_subnet.public_b.id
    vpc_security_group_ids = [aws_security_group.instances.id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 2" > index.html
        python3 -m http.server 8080 &
    EOF

    tags = {
        Name = "instance-2"
    }
}

# ------------------------------
# LOAD BALANCER
# ------------------------------
resource "aws_lb" "load_balancer" {
    name               = "web-app-lb"
    load_balancer_type = "application"
    subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "instances" {
    name     = "example-target-group"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

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

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = 404
        }
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

resource "aws_lb_listener_rule" "instances" {
    listener_arn = aws_lb_listener.http.arn
    priority     = 100

    condition {
        path_pattern {
        values = ["*"]
        }
    }

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.instances.arn
    }
}

# ------------------------------
# S3 BUCKET
# ------------------------------
resource "aws_s3_bucket" "bucket" {
    bucket_prefix = var.bucket_prefix
    force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
    bucket = aws_s3_bucket.bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_crypto_conf" {
    bucket = aws_s3_bucket.bucket.bucket
    rule {
        apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
        }
    }
}

# ------------------------------
# ROUTE 53
# ------------------------------
resource "aws_route53_zone" "primary" {
    name = var.domain
}

resource "aws_route53_record" "root" {
    zone_id = aws_route53_zone.primary.zone_id
    name    = var.domain
    type    = "A"

    alias {
        name                   = aws_lb.load_balancer.dns_name
        zone_id                = aws_lb.load_balancer.zone_id
        evaluate_target_health = true
    }
}

# ------------------------------
# RDS INSTANCE
# ------------------------------
resource "aws_db_subnet_group" "db_subnets" {
    name       = "db-subnet-group"
    subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_db_instance" "db_demo_instance" {
    allocated_storage    = var.rds_allocated_storage
    auto_minor_version_upgrade = true
    storage_type         = var.rds_storage_type
    engine               = var.rds_engine
    engine_version       = var.rds_engine_version
    instance_class       = var.rds_instance_class
    db_name              = var.db_name
    username             = var.db_user
    password             = var.db_pass
    skip_final_snapshot  = var.rds_skip_final_snapshot
    db_subnet_group_name = aws_db_subnet_group.db_subnets.name
    vpc_security_group_ids = [aws_security_group.instances.id]
}
