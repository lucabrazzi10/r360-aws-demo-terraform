variable "zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
}

variable "record_name" {
  description = "DNS name for the app (e.g. r360-demo.example.com)"
  type        = string
}

variable "primary_alb_dns" {
  description = "Primary region ALB DNS name"
  type        = string
}

variable "secondary_alb_dns" {
  description = "Secondary region ALB DNS name"
  type        = string
}
