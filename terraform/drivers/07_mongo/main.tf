provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}
terraform {
  required_version = ">= 0.12.19"
  backend "s3" {
  }
}

data "aws_vpc" "speculor-consulting-vpc" {
  filter {
    name   = "tag:Role"
    values = var.vpc_filter
  }
}

data "aws_security_group" "base_sg" {
  filter {
    name = "group-name"
    values = var.base_sg_filter
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-consulting-vpc.id]
  }
}

data "aws_security_group" "bastion_comm" {
  filter {
    name = "group-name"
    values = var.bastion_sg_filter
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-consulting-vpc.id]
  }
}

data "aws_caller_identity" "current" {
}

data "aws_ami" "mongo_ami" {
  most_recent = true
  filter {
    name   = "tag:Role"
    values = var.ami_filter
  }
  owners = [data.aws_caller_identity.current.account_id]
}

data "aws_subnet_ids" "mongo_subnet_ids" {
  vpc_id = data.aws_vpc.speculor-consulting-vpc.id
  filter {
    name   = "cidr-block"
    values = var.mongo_subnet_filter
  }
}

resource "aws_security_group" "mongo_sg" {
  name_prefix = "speculor-consulting-mongo-sg-"
  vpc_id      = data.aws_vpc.speculor-consulting-vpc.id
  description = "Security group for MongoDB instances within private subnets"

  tags = {
    Name = "speculor-consulting-mongo-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "mongo_ingress" {
  type              = "ingress"
  from_port         = "27017"
  to_port           = "27017"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mongo_sg.id
}

resource "aws_security_group_rule" "mongo_egress" {
  type              = "egress"
  from_port         = "27017"
  to_port           = "27017"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.mongo_sg.id
}

resource "aws_instance" "mongo" {
  for_each      = data.aws_subnet_ids.mongo_subnet_ids.ids
  ami           = data.aws_ami.mongo_ami.id
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
    Name      = format("speculor-consulting-mongo-volume-%s", each.value)
    Terraform = "true"
  }

  vpc_security_group_ids = [
    data.aws_security_group.base_sg.id,
    data.aws_security_group.bastion_comm.id,
    aws_security_group.mongo_sg.id
  ]

  tags = {
    Name        = format("speculor-consulting-mongo-%s", each.value)
    Terraform   = "true"
    Owner       = "Speculor Consulting"
    Department  = "Engineering"
    Project     = "infrastructure"
    Environment = "production"
    Role        = "speculor-consulting-mongo"
  }
}

output "mongo_ips" {
  value = {
    for instance in aws_instance.mongo:
      instance.id => instance.private_ip
  }
}
