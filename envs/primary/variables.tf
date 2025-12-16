variable "aws_region" { type = string }
variable "name_prefix" { type = string }

variable "db_master_username" {
  type      = string
  sensitive = true
}

variable "db_master_password" {
  type      = string
  sensitive = true
}

variable "app_instance_profile" {
  type    = string
  default = ""
}
