resource "aws_lb" "external_lbaas_kong" {

  name     = "externalLbaasKong"
  internal = false
  subnets  = [aws_subnet.subnet_lbaas_1.id, aws_subnet.subnet_lbaas_2.id] #data.aws_subnet_ids.public.ids

  security_groups = [aws_security_group.sg_lbaas_kong.id]

  #enable_deletion_protection = var.enable_deletion_protection
  idle_timeout = var.idle_timeout

}
resource "aws_security_group" "sg_lbaas_kong" {
  name   = "sg_lbaas_kong"
  vpc_id = aws_vpc.kong_vpc.id


  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
  }
  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_lbaas_kong"
  }
}

resource "aws_lb_listener" "external-http" {

  load_balancer_arn = aws_lb.external_lbaas_kong.arn
  port              = "80"
  protocol          = "HTTP"

  #ssl_policy      = var.ssl_policy
  #certificate_arn = data.aws_acm_certificate.external-cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.kong_tg.arn
    type             = "forward"
  }
}


# ---- target group
resource "aws_lb_target_group" "kong_tg" {

  name     = "kongtargetgroup"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.kong_vpc.id

  health_check {
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    path                = "/status"
    port                = 8001
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

}



resource "aws_lb_target_group_attachment" "tgr_attachment_0" {

  target_group_arn = aws_lb_target_group.kong_tg.arn
  target_id        = aws_instance.kong_vm_1.id
  port             = aws_lb_target_group.kong_tg.port
}

resource "aws_lb_target_group_attachment" "tgr_attachment_1" {

  target_group_arn = aws_lb_target_group.kong_tg.arn
  target_id        = aws_instance.kong_vm_2.id
  port             = aws_lb_target_group.kong_tg.port
}
