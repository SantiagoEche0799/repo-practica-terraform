terraform {
    backend "s3" {
        bucket         = "devops-directive-remote-tf-state"
        key            = "primera-arquitectura-simple/web-app-nueva-version/terraform.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-state-locking"
        encrypt        = true
    }

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~>5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

# --- NETWORKING ---
resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "webapp-vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "webapp-igw"
    }
}

# Subnet 1 - AZ a
resource "aws_subnet" "subnet_a" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-public-a"
    }
}

# Subnet 2 - AZ b
resource "aws_subnet" "subnet_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "subnet-public-b"
    }
}

# Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "public-rt"
    }
}

# Asociar subnets con la Route Table
resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.subnet_a.id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.subnet_b.id
    route_table_id = aws_route_table.public.id
}

# --- SECURITY GROUPS ---
resource "aws_security_group" "instances" {
    name   = "instance-security-group"
    vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
    type              = "ingress"
    security_group_id = aws_security_group.instances.id
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
}

# --- INSTANCIAS EC2 ---
resource "aws_instance" "instance_1" {
    ami             = "ami-0bbdd8c17ed981ef9"
    instance_type   = "t3.micro"
    subnet_id       = aws_subnet.subnet_a.id
    vpc_security_group_ids = [aws_security_group.instances.id]

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 1" > index.html
        python3 -m http.server 8080 &
    EOF

    tags = {
        Name = "web-instance-1"
    }
}

resource "aws_instance" "instance_2" {
    ami             = "ami-0bbdd8c17ed981ef9"
    instance_type   = "t3.micro"
    subnet_id       = aws_subnet.subnet_b.id
    vpc_security_group_ids = [aws_security_group.instances.id]

    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 2" > index.html
        python3 -m http.server 8080 &
    EOF

    tags = {
        Name = "web-instance-2"
    }
}

# --- S3 BUCKET ---
resource "aws_s3_bucket" "bucket" {
    bucket_prefix = "devops-directive-web-app-data"
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

# --- LOAD BALANCER ---
resource "aws_security_group" "alb" {
    name   = "alb-security-group"
    vpc_id = aws_vpc.main.id
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

resource "aws_lb" "load_balancer" {
    name               = "web-app-lb"
    load_balancer_type = "application"
    subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "instances" {
    name     = "example-target-group"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id

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
        type = "fixed-response"
        fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = 404
        }
    }
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

# --- ROUTE53 ---
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

# --- DATABASE ---
resource "aws_db_subnet_group" "default" {
    name        = "default-db-subnet-group"
    subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]
    description = "Default DB subnet group"
}

resource "aws_db_instance" "db_demo_instance" {
    allocated_storage          = 20
    auto_minor_version_upgrade = true
    storage_type               = "standard"
    engine                     = "postgres"
    engine_version             = "12"
    instance_class             = "db.t3.micro"
    db_name                    = "my_db_postgres"
    username                   = "demo_db_postgres"
    password                   = "santiago12"
    skip_final_snapshot        = true
    db_subnet_group_name       = aws_db_subnet_group.default.name
    vpc_security_group_ids     = [aws_security_group.instances.id]

    tags = {
        Name = "demo-db-instance"
    }
}
