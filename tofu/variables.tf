variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}
variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.27"
}
variable "primary_node_count" {
  description = "Number of nodes in the primary pool"
  type        = number
  default     = 3
}
variable "primary_node_size" {
  description = "Size of nodes in the primary pool"
  type        = string
  default     = "s-4vcpu-8gb"
}
variable "monitoring_node_count" {
  description = "Number of nodes in the monitoring pool"
  type        = number
  default     = 2
}
variable "monitoring_node_size" {
  description = "Size of nodes in the monitoring pool"
  type        = string
  default     = "c-4"
}
variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["prototype", "kubernetes"]
}
