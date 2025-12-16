variable "name"  { type = string }
variable "vpc_id" { type = string }

variable "subnet_ids" {
  type        = list(string)
  description = "Private app subnets in two AZs"
}

variable "ami_id"        { type = string }
variable "instance_type" { 
  type = string  
  default = "t3.small" 
  }

variable "db_endpoint" {
  type        = string
  description = "Postgres connection URL/host"
}

variable "efs_mount_target_dns" {
  type        = string
  default     = ""
  description = "Optional EFS DNS"
}

variable "iam_instance_profile_name" {
  type        = string
  default     = ""
}

variable "min_size"         {
   type = number 
   default = 2 
   } # like diagram – multiple app servers
variable "max_size"         {
   type = number
    default = 4
    }

variable "desired_capacity" {
   type = number 
   default = 2 
   }
