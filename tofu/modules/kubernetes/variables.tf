variable "name" {
  description = "Name of the Kubernetes cluster"
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
variable "vpc_id" {
  description = "ID of the VPC where the cluster will be created"
  type        = string
}
variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
  type        = string
}
variable "primary_node_count" {
  description = "Number of nodes in the primary node pool"
  type        = number
}
variable "primary_node_size" {
  description = "Size of the nodes in the primary node pool"
  type        = string
}
variable "monitoring_node_count" {
  description = "Number of nodes in the monitoring node pool"
  type        = number
}
variable "monitoring_node_size" {
  description = "Size of the nodes in the monitoring node pool"
  type        = string
}
variable "tags" {
  description = "Tags to apply to the cluster and node pools"
  type        = list(string)
  default     = []
}
