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

variable "bucket_name" {
  description = "Bucket name were the bastion will store the logs"
  default     = "speculor-consulting-bastion-logs"
}

variable "bucket_versioning" {
  default     = true
  description = "Enable bucket versioning or not"
}

variable "bucket_force_destroy" {
  default     = true
  description = "The bucket and all objects should be destroyed when using true"
}

variable "tags" {
  description = "A mapping of tags to assign"
  default = {
    Name        = "Speculor Consulting Bastion Host"
    Owner       = "Speculor Consulting"
    Department  = "Engineering"
    Project     = "Infrastructure"
    Environment = "Production"
    Role        = "speculor-consulting-bastion"
    Terraform   = "true"
  }
  type = map(string)
}

variable "region" {
  default = "us-west-2"
}

variable "cidrs" {
  description = "List of CIDRs than can access to the bastion. Default : 0.0.0.0/0"
  type        = list(string)

  default = [
    "0.0.0.0/0",
  ]
}

variable "is_lb_private" {
  description = "If TRUE the load balancer scheme will be \"internal\" else \"internet-facing\""
  default     = "false"
}

variable "bastion_host_key_pair" {
  description = "Select the key pair to use to launch the bastion host"
  default     = "speculor-bastion"
}

variable "hosted_zone_id" {
  description = "Name of the hosted zone were we'll register the bastion DNS name"
  default     = "speculorconsulting.com"
}

variable "bastion_record_name" {
  description = "DNS record name to use for the bastion"
  default     = "bastion.speculorconsulting.com"
}

variable "bastion_launch_template_name" {
  description = "Bastion Launch template Name, will also be used for the ASG"
  default     = "speculor-bastion"
}

variable "public_subnet_filter" {
  type        = list(string)
  description = "List of public subnets were the ELB will be deployed"
  default     = ["172.1.1.48/28", "172.1.1.64/28", "172.1.1.80/28"]
}

variable "private_subnet_filter" {
  type        = list(string)
  description = "List of private subnets were the Auto Scalling Group will deploy the instances"
  default     = ["172.1.1.0/28", "172.1.1.16/28", "172.1.1.32/28"]
}

variable "associate_public_ip_address" {
  default = true
}

variable "bastion_instance_count" {
  default = 2
}

variable "create_dns_record" {
  description = "Choose if you want to create a record name for the bastion (LB). If true 'hosted_zone_id' and 'bastion_record_name' are mandatory "
  default     = "true"
}

variable "log_auto_clean" {
  description = "Enable or not the lifecycle"
  default     = false
}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
}

variable "public_ssh_port" {
  description = "Set the SSH port to use from desktop to the bastion"
  default     = 22
}

variable "private_ssh_port" {
  description = "Set the SSH port to use between the bastion and private instance"
  default     = 22
}

variable "extra_user_data_content" {
  description = "Additional scripting to pass to the bastion host. For example, this can include installing postgresql for the `psql` command."
  type        = string
  default     = ""
}

variable "allow_ssh_commands" {
  description = "Allows the SSH user to execute one-off commands. Pass 'True' to enable. Warning: These commands are not logged and increase the vulnerability of the system. Use at your own discretion."
  type        = string
  default     = ""
}
