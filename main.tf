## Load Balancer ##

resource "aws_lb" "alb" {
  name               = var.instance_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.load_balancer_security_group]
  subnets            = var.load_balancer_subnets

  access_logs {
    bucket  = var.logs_bucket_address
    prefix  = "alb/access"
    enabled = true
  }

  connection {
    bucket  = var.logs_bucket_address
    prefix  = "alb/connection"
    enabled = true
  }

  tags = {
    Name = "${var.instance_name}-alb"
  }
}

## Load Balancer Listeners ##

resource "aws_lb_listener" "http-80" {
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

  tags = {
    Name = "${var.instance_name}-http-listener"
  }
}

# Certificate

/*

resource "aws_acm_certificate" "ssl-certificate" {
  certificate_body  = var.ssl_certificate.certificate_body
  private_key       = var.ssl_certificate.private_key
  certificate_chain = var.ssl_certificate.certificate_chain
}

 */

resource "aws_lb_listener" "http-443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.primary_ssl_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = ""
      status_code  = "404"
    }
  }

  tags = {
    Name = "${var.instance_name}-https-listener"
  }
}

resource "aws_lb_listener_certificate" "https_additional_certs" {
  count           = length(var.secondary_ssl_certificates_arn)
  listener_arn    = aws_lb_listener.http-443.arn
  certificate_arn = var.secondary_ssl_certificates_arn[count.index]
}