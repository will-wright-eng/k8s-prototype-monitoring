cluster_name          = "demo-argocd"
region                = "nyc3"
kubernetes_version    = "1.32.2-do.0"
node_pool_size        = "s-2vcpu-4gb"
node_count            = 2
environment           = "development"
namespace             = "demo"
monitoring_node_size  = "s-2vcpu-4gb"
monitoring_node_count = 1
