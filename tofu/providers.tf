provider "digitalocean" {
  token = var.do_token
}
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.cluster.endpoint
  token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  )
}
