resource "aws_security_group" "lb" {
  name          = "travelmate-alb-security-group"
  vpc_id        = aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

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

resource "aws_lb_listener" "travel_mate_server" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.travel_mate_server.id
    type             = "forward"
  }
}
