module "do_kubernetes" {
  source = "../../"
  # Environment-specific variables
  environment         = "dev"
  region              = "nyc1"
  kubernetes_version  = "1.27"
  # Node configurations
  primary_node_count    = 2  # Reduced count for dev environment
  primary_node_size     = "s-4vcpu-8gb"
  monitoring_node_count = 1  # Single monitoring node for dev
  monitoring_node_size  = "c-4"
  # Network configuration
  vpc_cidr           = "10.0.0.0/16"
  # Resource tagging
  tags               = ["prototype", "kubernetes", "dev"]
  # API token - this should be provided via environment variable
  do_token           = var.do_token
}
