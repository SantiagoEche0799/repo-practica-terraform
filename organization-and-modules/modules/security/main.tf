# Terraform file: main.tf for module security

# ==========================================
# SECURITY MODULE - SECURITY GROUPS
# ==========================================

resource "aws_security_group" "alb" {
    name   = "alb-sg"
    vpc_id = var.vpc_id
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
    name   = "instance-sg"
    vpc_id = var.vpc_id
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

