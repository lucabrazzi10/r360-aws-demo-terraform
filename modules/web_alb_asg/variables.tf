variable "name" {
  type        = string
  description = "Name prefix for web tier resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for web tier"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB and web ASG"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for web instances"
}

variable "instance_type" {
  type        = string
  description = "Instance type for web instances"
  default     = "t3.micro"
}

variable "app_backend_dns" {
  type        = string
  description = "DNS name of the app backend (typically an internal ALB) for Nginx proxy_pass"
}

variable "health_check_path" {
  type        = string
  description = "Health check path for the ALB target group"
  default     = "/health"
}

variable "min_size" {
  type        = number
  description = "Min web ASG size"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Max web ASG size"
  default     = 4
}

variable "desired_capacity" {
  type        = number
  description = "Desired web ASG size"
  default     = 2
}
