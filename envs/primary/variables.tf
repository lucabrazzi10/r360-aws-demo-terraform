variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

variable "app_instance_profile" {
  type = string
}
