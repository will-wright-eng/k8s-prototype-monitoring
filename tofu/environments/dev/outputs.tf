output "kubeconfig" {
  sensitive = true
  value     = module.kubernetes.kubeconfig
}

output "cluster_endpoint" {
  value = module.kubernetes.endpoint
}

output "cluster_id" {
  value = module.kubernetes.id
}
