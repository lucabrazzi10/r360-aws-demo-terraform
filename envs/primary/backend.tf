terraform {
  backend "s3" {
    bucket         = "r360-terraform-state-lucabrazzi10-us-east-1"
    key            = "envs/primary/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "r360-terraform-lock"
    encrypt        = true
  }
}
