variable "name_prefix" {
  type        = string
  description = "Name prefix for primary environment"
  default     = "r360-primary"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "db_master_username" {
  type        = string
  description = "DB master username"
  default     = "rgs"
}

variable "db_master_password" {
  type        = string
  description = "DB master password"
  sensitive   = true
}

variable "app_instance_profile" {
  type        = string
  description = "Optional IAM instance profile name for app instances"
  default     = ""
}
