resource "aws_lb" "app_lb" {
  name               = "feedbackapp-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  security_groups    = [aws_security_group.sg_alb.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "feedbackapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.feedback_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "public_ec2_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.public_ec2.id
  port             = 80
}
