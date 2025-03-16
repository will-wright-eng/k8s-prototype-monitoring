environment           = "dev"
region                = "nyc1"
vpc_cidr              = "10.0.0.0/16"
kubernetes_version    = "1.32"
primary_node_count    = 3
primary_node_size     = "s-4vcpu-8gb"
monitoring_node_count = 2
monitoring_node_size  = "c-4"
tags                  = ["prototype", "kubernetes"]
