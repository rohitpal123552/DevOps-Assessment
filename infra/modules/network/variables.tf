variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  description = "true = one shared NAT gateway (cheaper, for dev). false = one NAT per AZ."
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Port the app container listens on"
  type        = number
  default     = 80
}

variable "db_port" {
  type    = number
  default = 5432
}
