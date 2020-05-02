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

data "aws_instances" "bastion_instances" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.speculor-vpc.id]
  }
  filter {
    name   = "tag:Role"
    values = var.bastion_instance_filter
  }
}

data "aws_route_tables" "rts" {
  vpc_id = data.aws_vpc.speculor-vpc.id
}

data "aws_security_group" "bastion_host" {
  filter {
    name = "group-name"
    values = var.bastion_sg_filter
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-vpc.id]
  }
}

resource "aws_security_group_rule" "openvpn_ingress" {
  type              = "ingress"
  from_port         = "1194"
  to_port           = "1194"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.bastion_host.id
}

resource "aws_route" "vpn0_route" {
  count                  = length(data.aws_route_tables.rts.ids)
  route_table_id         = tolist(data.aws_route_tables.rts.ids)[count.index]
  destination_cidr_block = var.bastion_vpn0_cidr
  instance_id            = data.aws_instances.bastion_instances.ids[0]
}

resource "aws_route" "vpn1_route" {
  count                  = length(data.aws_route_tables.rts.ids)
  route_table_id         = tolist(data.aws_route_tables.rts.ids)[count.index]
  destination_cidr_block = var.bastion_vpn1_cidr
  instance_id            = data.aws_instances.bastion_instances.ids[1]
}

resource "null_resource" "disable_source_dest_check0" {
  provisioner "local-exec" {
    command = "aws ec2 modify-instance-attribute --no-source-dest-check --instance-id ${data.aws_instances.bastion_instances.ids[0]}  --region ${var.region}"
  }
}

resource "null_resource" "disable_source_dest_check1" {
  provisioner "local-exec" {
    command = "aws ec2 modify-instance-attribute --no-source-dest-check --instance-id ${data.aws_instances.bastion_instances.ids[1]}  --region ${var.region}"
  }
}

