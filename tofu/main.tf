resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = var.cluster_name
  region  = var.region
  version = var.kubernetes_version

  node_pool {
    name       = "${var.cluster_name}-worker-pool"
    size       = var.node_pool_size
    node_count = var.node_count
    labels = {
      environment = var.environment
      managed-by  = "terraform"
      node-type   = "primary"
    }
    tags = ["${var.cluster_name}-node", var.environment]
  }

  tags = ["${var.cluster_name}", var.environment]
}

# Add a dedicated monitoring node pool
resource "digitalocean_kubernetes_node_pool" "monitoring_pool" {
  cluster_id = digitalocean_kubernetes_cluster.cluster.id
  name       = "${var.cluster_name}-monitoring-pool"
  size       = var.monitoring_node_size
  node_count = var.monitoring_node_count

  labels = {
    environment = var.environment
    managed-by  = "terraform"
    node-type   = "monitoring" # This matches your Helm values
  }

  taint {
    key    = "dedicated"
    value  = "monitoring"
    effect = "NoSchedule"
  }

  tags = ["${var.cluster_name}-monitoring-node", var.environment]
}

resource "digitalocean_project" "project" {
  name        = "${var.cluster_name}-project"
  description = "A project to group ${var.environment} cluster resources"
  purpose     = "Demo/Learning"
  environment = var.environment
  resources = [
    digitalocean_kubernetes_cluster.cluster.urn
  ]
}

resource "digitalocean_container_registry" "registry" {
  name                   = "${var.cluster_name}-registry"
  subscription_tier_slug = "basic"
  region                 = var.region
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  depends_on = [digitalocean_kubernetes_cluster.cluster]
}

# Create a local file with kubeconfig
resource "local_file" "kubeconfig" {
  content         = digitalocean_kubernetes_cluster.cluster.kube_config[0].raw_config
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}
