provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
  }
}

data "aws_caller_identity" "current" {
}

data "aws_vpc" "speculor-vpc" {
  filter {
    name   = "tag:Role"
    values = var.vpc_filter
  }
}

data "aws_instances" "web-ids" {
  filter {
    name   = "tag:Role"
    values = var.web_id_filter
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-vpc.id]
  }
}

data "aws_network_interfaces" "web-nics" {
  filter {
    name   = "attachment.instance-id"
    values = data.aws_instances.web-ids.ids
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.speculor-vpc.id]
  }
}

data "aws_subnet_ids" "public-subnet-ids" {
  vpc_id = data.aws_vpc.speculor-vpc.id
  filter {
    name   = "cidr-block"
    values = var.public_subnet_filter
  }
}

data "template_file" "s3-policy" {
  template = file("policy.json.tpl")

  vars = {
    elb-account-id = var.elb_account_id
    aws-account-id = data.aws_caller_identity.current.account_id
    bucket-name    = var.log_bucket
    prefix         = var.log_prefix
    name           = var.name
  }
}

data "aws_acm_certificate" "cert" {
  domain   = var.domain
  statuses = ["ISSUED"]
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  policy = data.template_file.s3-policy.rendered
}

resource "aws_security_group" "alb-sg" {
  name_prefix = var.sg_name_prefix
  vpc_id      = data.aws_vpc.speculor-vpc.id
  description = "Security group for Speculor Application Load Balancer"
  tags = {
    Name        = var.name
    Terraform   = "true"
    Owner       = "Speculor Consulting"
    Department  = "engineering"
    Project     = "infrastructure"
    Environment = "production"
    Role        = "speculor-consulting-alb"
  }
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "http_egress" {
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "https_egress" {
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group" "alb-sg-internal" {
  name_prefix = "${var.sg_name_prefix}-internal"
  vpc_id      = data.aws_vpc.speculor-vpc.id
  description = "Security group for Speculor Application Load Balancer"
  tags = {
    Name        = var.name
    Terraform   = "true"
    Owner       = "Speculor Consulting"
    Department  = "engineering"
    Project     = "infrastructure"
    Environment = "production"
    Role        = "speculor-consulting-alb"
  }
}

resource "aws_security_group_rule" "http_ingress_internal" {
  type                     = "ingress"
  from_port                = "80"
  to_port                  = "80"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb-sg-internal.id
  source_security_group_id = aws_security_group.alb-sg.id
}

resource "aws_security_group_rule" "https_ingress_internal" {
  type                     = "ingress"
  from_port                = "443"
  to_port                  = "443"
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb-sg-internal.id
  source_security_group_id = aws_security_group.alb-sg.id
}

module "speculor-alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "= 5.1.0"
  name_prefix        = var.name_prefix
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.speculor-vpc.id
  subnets            = data.aws_subnet_ids.public-subnet-ids.ids
  security_groups    = [aws_security_group.alb-sg.id]
  access_logs = {
    bucket  = var.log_bucket
    prefix  = var.log_prefix
    enabled = true
  }
  target_groups = [
    {
      name_prefix      = var.name_prefix
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path    = var.health_check_path
        matcher = "200"
      }
    },
    {
      name_prefix      = var.name_prefix
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
      health_check = {
        path    = var.health_check_path
        matcher = "200"
      }
    }
  ]
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.aws_acm_certificate.cert.arn
      target_group_index = 0
    }
  ]
  tags = {
    Name        = var.name
    Terraform   = "true"
    Owner       = "Speculor Consulting"
    Department  = "engineering"
    Project     = "infrastructure"
    Environment = "production"
    Role        = "speculor-consulting-alb"
  }
}

resource "aws_lb_target_group_attachment" "speculor-alb-http-attachment" {
  for_each         = toset(data.aws_instances.web-ids.ids)
  target_group_arn = module.speculor-alb.target_group_arns[0]
  target_id        = each.value
  port             = 80
}

resource "aws_lb_target_group_attachment" "speculor-alb-https-attachment" {
  for_each         = toset(data.aws_instances.web-ids.ids)
  target_group_arn = module.speculor-alb.target_group_arns[1]
  target_id        = each.value
  port             = 443
}

resource "aws_network_interface_sg_attachment" "internal_sg_attachment" {
  for_each             = toset(data.aws_network_interfaces.web-nics.ids)
  security_group_id    = aws_security_group.alb-sg-internal.id
  network_interface_id = each.value
}

output "ALB-DNS-Name" {
  value = module.speculor-alb.this_lb_dns_name
}
