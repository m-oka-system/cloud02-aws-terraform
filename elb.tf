################################
# ALB
################################
resource "aws_lb" "alb" {
  name                       = "${var.prefix}-alb"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  # access_logs {
  #   bucket  = aws_s3_bucket.alb_log.id
  #   enabled = true
  # }

  security_groups = [
    aws_security_group.elb_sg.id
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect" # forwad / fixed-response / redirect

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.public.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name                 = "${var.prefix}-alb-tg"
  target_type          = "ip"
  vpc_id               = aws_vpc.vpc.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }

  depends_on = [aws_lb.alb]
}

resource "aws_lb_target_group_attachment" "alb_tg" {
  for_each         = toset(["10.0.11.11", "10.0.12.11"])
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = each.key
}

################################
# Route 53 (Alias record)
################################
resource "aws_route53_record" "alb" {
  name    = "www.${aws_route53_zone.public.name}"
  zone_id = aws_route53_zone.public.zone_id
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
