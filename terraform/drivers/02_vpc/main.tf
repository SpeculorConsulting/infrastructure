provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.33.0"

  name = "speculor-vpc"

  cidr = "172.1.1.0/24"

  azs                 = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets     = ["172.1.1.0/28", "172.1.1.16/28", "172.1.1.32/28"]
  public_subnets      = ["172.1.1.48/28", "172.1.1.64/28", "172.1.1.80/28"]
  database_subnets    = ["172.1.1.96/28", "172.1.1.112/28", "172.1.1.128/28"]

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "speculorconsulting.com"

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = true
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true

  tags = {
    Owner       = "Speculor Consulting"
    Environment = "Production"
    Name        = "Speculor Consulting VPC"
  }

  vpc_endpoint_tags = {
    Project  = "Secret"
    Endpoint = "true"
  }
}
