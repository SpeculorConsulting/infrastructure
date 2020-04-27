variable "bucket" {
  type        = string
  default     = "speculor-terraform-bucket"
  description = "Unique name to give to S3 bucket used for the Terraform backend"
}

variable "table" {
  type        = string
  default     = "speculor-terraform-table"
  description = "Unique name to give to DynamoDB table used for the Terraform state lock"
}
