variable "vpc_filter" {
  description = "Filters VPCs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-vpc"]
}

variable "ami_filter" {
  description = "Filters AMIs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-bastion"]
}

variable "bastion_instance_filter" {
  description = "Filters ec2 instances based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-bastion"]
}

variable "bastion_sg_filter" {
  description = "Filters ec2 instances based of of the Role tag"
  type        = list(string)
  default     = ["speculor-bastion-host"]
}

variable "bastion_vpn0_cidr" {
  description = "VPN network 0"
  default     = "10.1.1.0/24"
}

variable "bastion_vpn1_cidr" {
  description = "VPN network 1"
  default     = "10.2.1.0/24"
}
