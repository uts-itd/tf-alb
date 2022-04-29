resource "aws_security_group" "alb" {
  name        = "${var.lb_name}-alb-sg"
  description = "A security group used by the ${var.lb_name} application load balancer"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.lb_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids != null ? var.public_subnet_ids : data.aws_subnet_ids.default[0].ids
  ip_address_type    = "ipv4"

  dynamic "access_logs" {
    for_each = var.alb_log_bucket_name != null ? ["enabled"] : []
    content {
      bucket  = var.alb_log_bucket_name
      prefix  = var.alb_log_prefix
      enabled = true
    }
  }
}
# resource "aws_wafregional_web_acl_association" "alb" {
#   count        = length(var.regional_waf_acl_id) == 0 ? 0 : 1
#   resource_arn = aws_lb.alb.arn
#   web_acl_id   = var.regional_waf_acl_id
# }

resource "aws_lb_target_group" "alb" {
  name                 = "${var.lb_name}-tg"
  port                 = var.container_port
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 20

  health_check {
    interval            = 30
    path                = var.health_check_path
    port                = var.container_port
    protocol            = "HTTP"
    timeout             = 2
    healthy_threshold   = 10
    unhealthy_threshold = 10
    matcher             = "200-399"
  }

  # apparently there is a bug with NLB stickiness right now
  # and this is the work around, not sure how it will affect ALBs
  #stickiness {
  #  enabled = false
  #  type    = "lb_cookie"
  #}
}

# If a certificate is provided, will redirect 80 to 443 and 443 will forward to target group
resource "aws_lb_listener" "redirect_to_https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "forward_https" {
  count             = var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

# If no certificate is provided, 80 will forward to the target group
resource "aws_lb_listener" "forward_http" {
  count             = var.certificate_arn != null ? 0 : 1
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}
