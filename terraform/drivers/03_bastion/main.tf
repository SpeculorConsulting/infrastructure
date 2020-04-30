provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
  }
}

data "aws_vpc" "speculor-vpc" {
  filter {
    name   = "tag:Role"
    values = var.vpc_filter
  }
}

data "aws_subnet_ids" "public_subnet_ids" {
  vpc_id = data.aws_vpc.speculor-vpc.id
  filter {
    name   = "cidr-block"
    values = var.public_subnet_filter
  }
}

data "aws_subnet_ids" "private_subnet_ids" {
  vpc_id = data.aws_vpc.speculor-vpc.id
  filter {
    name   = "cidr-block"
    values = var.private_subnet_filter
  }
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "bastion_ami" {
  most_recent = true
  filter {
    name   = "tag:Role"
    values = var.ami_filter
  }
  owners = [data.aws_caller_identity.current.account_id]
}

module "bastion" {
  source  = "Guimove/bastion/aws"
  version = "1.2.1"

  vpc_id                       = data.aws_vpc.speculor-vpc.id
  bastion_ami                  = data.aws_ami.bastion_ami.id
  elb_subnets                  = data.aws_subnet_ids.public_subnet_ids.ids
  auto_scaling_group_subnets   = data.aws_subnet_ids.private_subnet_ids.ids

  bucket_name                  = var.bucket_name
  bucket_versioning            = var.bucket_versioning
  bucket_force_destroy         = var.bucket_force_destroy
  tags                         = var.tags
  region                       = var.region
  cidrs                        = var.cidrs
  is_lb_private                = var.is_lb_private
  bastion_host_key_pair        = var.bastion_host_key_pair
  hosted_zone_id               = var.hosted_zone_id
  bastion_record_name          = var.bastion_record_name
  bastion_launch_template_name = var.bastion_launch_template_name
  associate_public_ip_address  = var.associate_public_ip_address
  bastion_instance_count       = var.bastion_instance_count
  create_dns_record            = var.create_dns_record
  log_auto_clean               = var.log_auto_clean
  log_standard_ia_days         = var.log_standard_ia_days
  log_glacier_days             = var.log_glacier_days
  log_expiry_days              = var.log_expiry_days
  public_ssh_port              = var.public_ssh_port
  private_ssh_port             = var.private_ssh_port
  extra_user_data_content      = var.extra_user_data_content
  allow_ssh_commands           = var.allow_ssh_commands
}
