variable "vpc_filter" {
  description = "Filters VPCs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-consulting-vpc"]
}

variable "web_id_filter" {
  description = "Filters AMIs based of of the Role tag"
  type        = list(string)
  default     = ["speculor-nginx"]
}

variable "public_subnet_filter" {
  description = "Filters subnets based of of the cidr-block"
  type        = list(string)
  default     = ["172.1.1.48/28", "172.1.1.64/28", "172.1.1.80/28"]
}

variable "log_bucket" {
  description = "Name of the encrypted s3 bucket to create for logs"
  default     = "speculor-consulting-alb-logs"
}

variable "log_prefix" {
  description = "String to begin log file names with"
  default     = "alb"
}

variable "sg_name_prefix" {
  description = "String to begin security group names with"
  default     = "speculor-alb-sg"
}

variable "name_prefix" {
  description = "String to begin alb names with"
  default     = "speclr"
}

variable "name" {
  description = "String to begin resource names with"
  default     = "speculor-alb"
}

variable "domain" {
  description = "Route53 domain"
  default     = "speculorconsulting.com"
}

variable "health_check_path" {
  description = "Path to test for 200 response code"
  default     = "/index.html"
}

variable "elb_account_id" {
  description = "ID of the AWS elb account for a given region as per https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html#attach-bucket-policy. Default is for us-west-2"
  default     = "797873946194"
}
