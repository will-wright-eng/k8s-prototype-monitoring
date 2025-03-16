# Operations Guide

This document provides operational procedures for managing the Kubernetes prototype.

## Initial Setup

### Prerequisites

Ensure the following tools are installed:

- OpenTofu (or Terraform) v1.5.0+
- kubectl
- Helm
- doctl (DigitalOcean CLI)

### Provisioning Infrastructure

1. Set up DigitalOcean API token:

   ```bash
   export DO_TOKEN=your_digitalocean_api_token
   ```

2. Initialize OpenTofu:

   ```bash
   cd tofu/environments/dev
   tofu init
   ```

3. Apply the configuration:

   ```bash
   tofu apply -var="do_token=$DO_TOKEN"
   ```

4. Configure kubectl:

   ```bash
   tofu output -raw kubeconfig > ~/.kube/config
   ```

### Deploying Core Services

1. Deploy ArgoCD:

   ```bash
   kubectl apply -f k8s/bootstrap/argocd/install.yaml
   ```

2. Access ArgoCD UI:

   ```bash
   kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

3. Deploy the monitoring stack:

   ```bash
   kubectl apply -f k8s/apps/system/argocd-apps.yaml
   ```

## Routine Operations

### Terraform State Management

The terraform state is stored locally. To maintain it:

1. Back up the state file after changes:

   ```bash
   cp terraform.tfstate terraform.tfstate.backup
   ```

2. For team environments, consider using version control (git) with .gitignore rules for the state files.

### Scaling the Cluster

1. Adjust node count in terraform variables:

   ```hcl
   primary_node_count = 4  # Increase from 3 to 4
   ```

2. Apply the changes:

   ```bash
   tofu apply -var="do_token=$DO_TOKEN"
   ```

### Upgrading Kubernetes Version

1. Update the kubernetes_version variable in terraform:

   ```hcl
   kubernetes_version = "1.28"
   ```

2. Apply the changes:

   ```bash
   tofu apply -var="do_token=$DO_TOKEN"
   ```

### Monitoring and Alerts

1. Access Grafana:

   ```bash
   kubectl get svc -n monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
   ```

2. Default login: admin / changeme (change this in production)

### Log Analysis

1. In Grafana, select Loki as the data source
2. Use LogQL to query logs, e.g.:

   ```
   {namespace="monitoring"}
   ```

## Backup and Recovery

### Terraform State Backup

1. Create regular backups of the terraform.tfstate file:

   ```bash
   cp terraform.tfstate backups/terraform.tfstate.$(date +%Y%m%d)
   ```

### Kubernetes Resources Backup

1. For key resources, consider using:

   ```bash
   kubectl get namespace monitoring -o yaml > backup-monitoring-ns.yaml
   ```

### Persistent Volume Backup

1. For critical data, consider taking DigitalOcean volume snapshots.

## Troubleshooting

### Common Issues

1. **Terraform apply fails**:
   - Check DigitalOcean API token validity
   - Verify VPC resources don't conflict

2. **ArgoCD can't sync applications**:
   - Check Git repository connectivity
   - Verify RBAC permissions in the cluster

3. **Monitoring stack not working**:
   - Check node affinity and tolerations
   - Verify persistent volume claims are bound

### Getting Help

For further assistance:

- DigitalOcean Documentation: <https://docs.digitalocean.com/products/kubernetes/>
- ArgoCD Documentation: <https://argo-cd.readthedocs.io/>
- Grafana Documentation: <https://grafana.com/docs/>
