variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
}

variable "ip_range" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
