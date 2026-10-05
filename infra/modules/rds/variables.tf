variable "name" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnets for the DB subnet group"
  type        = list(string)
}

variable "security_group_id" {
  type = string
}

variable "engine_version" {
  description = "Postgres version. A major version only (like 16) lets AWS pick the minor."
  type        = string
  default     = "16"
}

variable "instance_class" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling"
  type        = number
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "backup_retention_days" {
  type = number
}

variable "deletion_protection" {
  type = bool
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}
