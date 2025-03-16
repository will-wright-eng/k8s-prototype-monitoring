terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
  }
  required_version = ">= 1.5.0"
}
provider "digitalocean" {
  token = var.do_token
}
# Create a new VPC
module "vpc" {
  source      = "./modules/vpc"
  name        = "${var.environment}-vpc"
  region      = var.region
  ip_range    = var.vpc_cidr
}
# Create a Kubernetes cluster
module "kubernetes" {
  source              = "./modules/kubernetes"
  name                = "${var.environment}-k8s-cluster"
  region              = var.region
  vpc_id              = module.vpc.id
  kubernetes_version  = var.kubernetes_version
  # Primary node pool
  primary_node_count  = var.primary_node_count
  primary_node_size   = var.primary_node_size
  # Monitoring node pool
  monitoring_node_count = var.monitoring_node_count
  monitoring_node_size  = var.monitoring_node_size
  # Tags for resource organization
  tags                = var.tags
}
# Configure kubernetes provider with cluster details
provider "kubernetes" {
  host                   = module.kubernetes.endpoint
  token                  = module.kubernetes.token
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
}
# Configure helm provider
provider "helm" {
  kubernetes {
    host                   = module.kubernetes.endpoint
    token                  = module.kubernetes.token
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  }
}
# Output the kubeconfig for cluster access
output "kubeconfig" {
  sensitive = true
  value     = module.kubernetes.kubeconfig
}
# Output cluster details
output "cluster_endpoint" {
  value = module.kubernetes.endpoint
}
output "cluster_id" {
  value = module.kubernetes.id
}
