output "lb_http_443_listener" {
  value = aws_lb_listener.http-443
}

output "lb_dns_record" {
  value = aws_lb.alb.dns_name
}