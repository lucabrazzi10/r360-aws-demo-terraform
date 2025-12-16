output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "app_alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "app_alb_sg_id" {
  value = aws_security_group.app_alb_sg.id
}

