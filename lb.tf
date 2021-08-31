resource "aws_lb" "default" {
  name          = "travelmate-lb-${var.env_name}"
  subnets       = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "travel_mate_server" {
  name          = "travel-mate-server-target-${var.env_name}"
  port          = 80
  protocol      = "HTTP"
  vpc_id        = aws_vpc.default.id
  target_type   = "ip"
}

resource "aws_lb_target_group" "travel_mate_client" {
  name          = "travel-mate-client-target-${var.env_name}"
  port          = 80
  protocol      = "HTTP"
  vpc_id        = aws_vpc.default.id
  target_type   = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  # We auto-upgrade the HTTP connection to HTTPS
  default_action {
    type            = "redirect"

    redirect {
      port          = "443"
      protocol      = "HTTPS"
      status_code   = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.default.id
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_cert_arn
  
  default_action {
    target_group_arn = aws_lb_target_group.travel_mate_client.id
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "api" {
  listener_arn       = aws_lb_listener.https.arn
  priority           = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.travel_mate_server.id
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
