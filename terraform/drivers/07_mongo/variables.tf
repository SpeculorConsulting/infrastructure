variable "vpc_filter" {
  description = "Filters VPCs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-vpc"]
}

variable "ami_filter" {
  description = "Filters AMIs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-mongo"]
}

variable "base_sg_filter" {
  type        = list(string)
  description = "Filters base security groups based of of the group name"
  default     = ["default"]
}

variable "bastion_sg_filter" {
  type        = list(string)
  description = "Filters bastion security groups based of of the group name"
  default     = ["speculor-bastion-priv-instances"]
}

variable "mongo_subnet_filter" {
  type        = list(string)
  description = "List of private subnets were the mongo servers will be deployed"
  default     = ["172.1.1.0/28"]
}

variable "vol_size" {
  description = "Volume size of the mongo instances in GB"
  default     = "100"
}

variable "instance_type" {
  description = "Ec2 instance type of mongo instances"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name used to create the ec2 instance"
  default     = "speculor-mongo"
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring on the ec2 instance"
  default     = "true"
}
