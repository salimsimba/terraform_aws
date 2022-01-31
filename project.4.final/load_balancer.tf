## AWS Load Balancer {{{1
resource "aws_lb" "alb" {
  name               = "${local.prefix}-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.AlbSG.id]

  subnets = [
    aws_subnet.publicA.id,
    aws_subnet.publicB.id,
    aws_subnet.publicC.id
  ]

  tags = local.common_tags
}

resource "aws_lb_target_group" "app_target_grp" {
  name        = "${local.prefix}-app-alb-tg"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"
  port        = var.app_container_port

  health_check {
    enabled            = true
    port                = 80
    protocol            = "HTTP"
    path                = "/test"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_grp.arn
  }
}

resource "aws_autoscaling_attachment" "target" {
  autoscaling_group_name = aws_autoscaling_group.ec2_app_asg.id
  alb_target_group_arn   = aws_lb_target_group.app_target_grp.arn
}
## }}}1

output "alb_dns_name" { value = aws_lb.alb.dns_name }
