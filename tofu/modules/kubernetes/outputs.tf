output "id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.id
}
output "name" {
  description = "Name of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.name
}
output "endpoint" {
  description = "Endpoint for the Kubernetes API"
  value       = digitalocean_kubernetes_cluster.main.endpoint
}
output "token" {
  description = "Token for accessing the Kubernetes API"
  value       = digitalocean_kubernetes_cluster.main.kube_config[0].token
  sensitive   = true
}
output "cluster_ca_certificate" {
  description = "CA certificate for the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive   = true
}
output "kubeconfig" {
  description = "Kubernetes configuration file content"
  value       = digitalocean_kubernetes_cluster.main.kube_config[0].raw_config
  sensitive   = true
}
