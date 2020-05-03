variable "vpc_filter" {
  description = "Filters VPCs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-vpc"]
}

variable "ami_filter" {
  description = "Filters AMIs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-nginx"]
}

variable "bastion_sg_filter" {
  type        = list(string)
  description = "Filters security groups based of of the group name"
  default     = ["speculor-bastion-priv-instances"]
}

variable "nginx_subnet_filter" {
  type        = list(string)
  description = "List of private subnets were the nginx servers will be deployed"
  default     = ["172.1.1.0/28", "172.1.1.16/28"]
}

variable "vol_size" {
  description = "Volume size of the nginx instances in GB"
  default     = "20"
}

variable "instance_type" {
  description = "Ec2 instance type of nginx instances"
  default     = "t3.nano"
}

variable "key_name" {
  description = "SSH key pair name used to create the ec2 instance"
  default     = "speculor-nginx"
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring on the ec2 instance"
  default     = "true"
}
