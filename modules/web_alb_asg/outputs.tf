output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}



output "web_sg_id" {
  value       = aws_security_group.web_sg.id
  description = "Security group ID for the web tier"
}
