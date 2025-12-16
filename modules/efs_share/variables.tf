variable "name" {
  description = "Name prefix for EFS"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs where mount targets will be created"
  type        = list(string)
}
