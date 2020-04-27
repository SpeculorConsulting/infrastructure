provider "aws" {
  region  = "us-west-2"
  version = "~> 2.0"
}

terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
  }
}

resource "aws_iam_role" "devops-admin" {
  name               = var.admin_role
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDevopsAdminAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::573746086717:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "NumericLessThan": {
          "aws:MultiFactorAuthAge": "28800"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role" "devops-user" {
  name               = var.user_role
  path               = "/"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowDevopsUserAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::573746086717:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "NumericLessThan": {
          "aws:MultiFactorAuthAge": "28800"
        }
      }
    }
  ]
}
POLICY
}

data "aws_iam_policy" "IAMFullAccess" {
  arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "SecurityAudit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

data "aws_iam_policy" "PowerUserAccess" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "IAMFullAccess" {
  role       = aws_iam_role.devops-admin.name
  policy_arn = data.aws_iam_policy.IAMFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  role       = aws_iam_role.devops-admin.name
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

resource "aws_iam_role_policy_attachment" "SecurityAudit" {
  role       = aws_iam_role.devops-admin.name
  policy_arn = data.aws_iam_policy.SecurityAudit.arn
}

resource "aws_iam_role_policy_attachment" "PoweruserAccess" {
  role       = aws_iam_role.devops-user.name
  policy_arn = data.aws_iam_policy.PowerUserAccess.arn
}
