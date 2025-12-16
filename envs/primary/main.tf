terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
#  VPC (public, app, db subnets)
# -----------------------------
module "vpc" {
  source = "../../modules/vpc"

  name                     = var.name_prefix
  cidr_block               = "10.10.0.0/16"
  azs                      = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs      = ["10.10.1.0/24", "10.10.2.0/24"]
  private_app_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  private_db_subnet_cidrs  = ["10.10.21.0/24", "10.10.22.0/24"]
}

# -----------------------------
#  EFS share (mounted by app)
# -----------------------------
module "efs" {
  source = "../../modules/efs_share"

  name       = var.name_prefix
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_app_subnet_ids
}

# -----------------------------
#  RDS
# -----------------------------
module "db" {
  source = "../../modules/rds"

  name              = "heliopay"
  vpc_id            = module.vpc.vpc_id
  db_subnet_ids     = module.vpc.private_db_subnet_ids
  allocated_storage = 50
  engine_version    = "15.13"
  instance_class    = "db.t3.medium"
  username          = var.db_master_username
  password          = var.db_master_password
  multi_az          = true
}

# -----------------------------
#  AMI for web / app
# -----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# -----------------------------
#  APP TIER – ASG in private subnets
# -----------------------------
module "app_asg" {
  source = "../../modules/app_asg"

  name                      = "heliopay-app"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_app_subnet_ids
  ami_id                    = data.aws_ami.amazon_linux.id
  instance_type             = "t3.small"
  db_endpoint               = module.db.primary_endpoint
  efs_mount_target_dns      = module.efs.efs_dns_name
  iam_instance_profile_name = var.app_instance_profile

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
}

# -----------------------------
#  WEB TIER – ALB + ASG in public subnets
# -----------------------------
module "web" {
  source = "../../modules/web_alb_asg"

  name              = "${var.name_prefix}-web"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  instance_type   = "t3.micro"
  ami_id          = data.aws_ami.amazon_linux.id
  app_backend_dns = module.app_asg.app_alb_dns_name

  min_size         = 2
  max_size         = 2
  desired_capacity = 2
}

# -----------------------------
#  SG rules between tiers
# -----------------------------
resource "aws_security_group_rule" "app_from_web" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = module.app_asg.app_alb_sg_id
  source_security_group_id = module.web.web_sg_id
}

resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port                = module.db.db_port
  to_port                  = module.db.db_port
  protocol                 = "tcp"
  security_group_id        = module.db.db_sg_id
  source_security_group_id = module.app_asg.app_sg_id
}
