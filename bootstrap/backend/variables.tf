variable "aws_region" {
  type        = string
  description = "AWS region for Terraform backend"
  default     = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state"
}

variable "lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"
  default     = "r360-terraform-lock"
}
