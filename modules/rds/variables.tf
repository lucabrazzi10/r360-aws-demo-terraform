variable "name"          { type = string }
variable "vpc_id"        { type = string }
variable "db_subnet_ids" { type = list(string) }

variable "allocated_storage" {
  type    = number
  default = 50
}

variable "engine_version" {
  type    = string
  default = "15.4"
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "username" { type = string }
variable "password" {
  type      = string
  sensitive = true
}

variable "multi_az" {
  type    = bool
  default = true
}
