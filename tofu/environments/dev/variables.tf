variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
}

variable "primary_node_count" {
  description = "Number of nodes in the primary pool"
  type        = number
}

variable "primary_node_size" {
  description = "Size of nodes in the primary pool"
  type        = string
}

variable "monitoring_node_count" {
  description = "Number of nodes in the monitoring pool"
  type        = number
}

variable "monitoring_node_size" {
  description = "Size of nodes in the monitoring pool"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
}
