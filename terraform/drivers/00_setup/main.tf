provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12.0"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket
  force_destroy = true
  acceleration_status = "Enabled"
  versioning {
    enabled = true
  }

  tags = {
    Name        = "Speculor Consulting State Bucket"
    Owner       = "Speculor Consulting"
    Department  = "Engineering"
    Project     = "Infrastructure"
    Environment = "Production"
    Terraform   = "true"
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.table
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Speculor Consulting State Lock Table"
    Owner       = "Speculor Consulting"
    Department  = "Engineering"
    Project     = "Infrastructure"
    Environment = "Production"
    Terraform   = "true"
  }
}
