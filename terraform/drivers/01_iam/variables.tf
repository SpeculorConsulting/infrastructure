variable "admin_role" {
  type        = string
  default     = "speculor-admin"
  description = "Name of role for Speculor admins"
}

variable "user_role" {
  type        = string
  default     = "speculor-user"
  description = "Name of role for Speculor users"
}
