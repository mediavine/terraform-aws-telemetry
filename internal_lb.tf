resource "aws_lb" "this" {
    count = var.enable_internal_lb && var.create_adot_service ? 1 : 0
    
    name = "${var.name}-internal-otel-collector-lb"
    internal = true
    load_balancer_type = "application"
    security_groups = [var.security_groups]
    subnets = [var.subnets]

    dynamic "subnet_mapping" {
      for_each = var.subnets
        content {
            subnet_id = subnet_mapping.value
        }
    }
}

resource "aws_lb_target_group" "this" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  name         = "${var.name}-internal-otel-collector-tg"
  port         = 4318
  protocol     = "HTTP"
  target_type  = "ip"
  vpc_id       = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}