

# Create the Target Group for the ALB
resource "aws_lb_target_group" "strapi_servers" {
  name     = "${local.project}-strapi-servers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.networking.outputs.vpc_id

  health_check {
    path = "/"
    port = "80"
  }
}

# Create a security group for the ALB and EC2 instances
resource "aws_security_group" "alb_sg" {
  name   = "${local.project}-strapi-alb-sg"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

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

  tags = merge({ Name = "${local.project}-strapi-alb-sg" }, local.default_tags)
}


# Create the Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.project}-strapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.terraform_remote_state.networking.outputs.public_subnets_ids

  tags = merge({ Name = "${local.project}-strapi-alb" }, local.default_tags)
}


# Create a Listener for the ALB
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
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

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.strapi_servers.arn
  }
}