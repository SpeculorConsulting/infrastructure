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

data "aws_security_group" "bastion_sg" {
  filter {
    name   = "group-name"
    values = var.bastion_sg_filter
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-vpc.id]
  }
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "nginx_ami" {
  most_recent = true
  filter {
    name   = "tag:Role"
    values = var.ami_filter
  }
  owners = [data.aws_caller_identity.current.account_id]
}

data "aws_subnet_ids" "nginx_subnet_ids" {
  vpc_id = data.aws_vpc.speculor-vpc.id
  filter {
    name   = "cidr-block"
    values = var.nginx_subnet_filter
  }
}

resource "aws_security_group" "nginx_sg" {
  name_prefix = "speculor-nginx-sg-"
  vpc_id      = data.aws_vpc.speculor-vpc.id
  description = "Security group for MongoDB instances within private subnets"

  tags = {
    Name = "speculor-nginx-sg"
  }
}

resource "aws_security_group_rule" "nginx_http_ingress" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nginx_sg.id
}

resource "aws_security_group_rule" "nginx_https_ingress" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nginx_sg.id
}

resource "aws_security_group_rule" "nginx_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "65535"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nginx_sg.id
}

resource "aws_instance" "nginx" {
  for_each      = data.aws_subnet_ids.nginx_subnet_ids.ids
  ami           = data.aws_ami.nginx_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = each.value
  monitoring    = var.enable_monitoring

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.vol_size
    delete_on_termination = true
  }

  volume_tags = {
    Name      = format("speculor-nginx-volume-%s", each.value)
    Terraform = "true"
  }

  vpc_security_group_ids = [
    data.aws_security_group.bastion_sg.id,
    aws_security_group.nginx_sg.id
  ]

  tags = {
    Name        = format("speculor-nginx-%s", each.value)
    Terraform   = "true"
    owner       = "Speculor Consulting"
    department  = "Engineering"
    Project     = "infrastructure"
    Environment = "production"
    Role        = "speculor-nginx"
  }
}

output "nginx_ips" {
  value = {
    for instance in aws_instance.nginx :
    instance.id => instance.private_ip
  }
}
