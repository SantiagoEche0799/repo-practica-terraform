# Terraform file: main.tf for module alb

# ==========================================
# ALB MODULE
# ==========================================

resource "aws_lb" "load_balancer" {
    name               = "web-app-lb"
    load_balancer_type = "application"
    subnets            = var.subnets
    security_groups    = [var.alb_sg_id]
}

resource "aws_lb_target_group" "instances" {
    name     = "target-group"
    port     = 8080
    protocol = "HTTP"
    vpc_id   = var.vpc_id

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
    target_id        = var.instances_ids[0]
    port             = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
    target_group_arn = aws_lb_target_group.instances.arn
    target_id        = var.instances_ids[1]
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

