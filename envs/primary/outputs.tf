output "web_alb_dns_name" {
  value       = module.web.alb_dns_name
  description = "Public web ALB DNS name"
}

output "app_internal_alb_dns_name" {
  value       = module.app_asg.app_alb_dns_name
  description = "Internal app ALB DNS name"
}

output "rds_primary_endpoint" {
  value       = module.db.primary_endpoint
  description = "RDS primary endpoint"
}

output "efs_id" {
  value       = module.efs.efs_id
  description = "EFS filesystem ID"
}
