data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_lb" "this" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  name               = "${var.name}-internal-collector-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this[0].id]
  subnets            = var.subnets
}

resource "aws_lb_listener" "this" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 13133
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

resource "aws_lb_target_group" "this" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  name        = "${var.name}-internal-collector-tg"
  port        = 13133
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  depends_on = [aws_lb.this]
}

################################################################################
# Security Group & Rules
################################################################################
resource "aws_security_group" "this" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  name        = "${var.name}-internal-collector-sg"
  description = "Security group for the internal collector load balancer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "health_check" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  type              = "ingress"
  from_port         = 13133
  to_port           = 13133
  protocol          = "tcp"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "http" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  type              = "ingress"
  from_port         = 4318
  to_port           = 4318
  protocol          = "TCP"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = [data.aws_vpc.this.cidr_block]
}

resource "aws_security_group_rule" "egress" {
  count = var.enable_internal_lb && var.create_adot_service ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.this[0].id
  cidr_blocks       = ["0.0.0.0/0"]
}