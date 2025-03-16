resource "digitalocean_kubernetes_cluster" "main" {
  name          = var.name
  region        = var.region
  version       = var.kubernetes_version
  vpc_uuid      = var.vpc_id
  auto_upgrade  = false
  surge_upgrade = true
  ha            = false  # Enable HA for production
  # Primary node pool
  node_pool {
    name       = "${var.name}-primary"
    size       = var.primary_node_size
    node_count = var.primary_node_count
    auto_scale = false
    tags       = concat(var.tags, ["primary"])
    labels = {
      "node-type" = "primary"
    }
  }
  tags = var.tags
}
# Adding monitoring node pool
resource "digitalocean_kubernetes_node_pool" "monitoring" {
  cluster_id = digitalocean_kubernetes_cluster.main.id
  name       = "${var.name}-monitoring"
  size       = var.monitoring_node_size
  node_count = var.monitoring_node_count
  auto_scale = false
  tags       = concat(var.tags, ["monitoring"])
  labels = {
    "node-type" = "monitoring"
  }
  taint {
    key    = "dedicated"
    value  = "monitoring"
    effect = "NoSchedule"
  }
}
# Create a local file with kubeconfig
resource "local_file" "kubeconfig" {
  content         = digitalocean_kubernetes_cluster.main.kube_config[0].raw_config
  filename        = "${path.module}/kubeconfig"
  file_permission = "0600"
}
