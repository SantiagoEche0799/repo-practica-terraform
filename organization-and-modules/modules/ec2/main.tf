# Terraform file: main.tf for module ec2


# ==========================================
# EC2 MODULE
# ==========================================

resource "aws_instance" "instance_1" {
    ami                    = var.ami
    instance_type          = var.instance_type
    subnet_id              = var.subnets[0]
    vpc_security_group_ids = [var.security_group_id]
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
    subnet_id              = var.subnets[1]
    vpc_security_group_ids = [var.security_group_id]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, world 2" > index.html
        python3 -m http.server 8080 &
    EOF

    tags = {
        Name = "instance-2"
    }
}

