# Kubernetes Prototype on DigitalOcean
This repository contains infrastructure code and configuration for a prototype Kubernetes cluster on DigitalOcean using Terraform, Helm, ArgoCD, and the Grafana monitoring stack.
## Repository Structure
- `terraform/` - Infrastructure as Code using Terraform
- `kubernetes/` - Kubernetes manifests and configuration
- `helm-values/` - Custom values for Helm charts
- `docs/` - Documentation and architecture diagrams
## Getting Started
### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) v1.5.0+
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [doctl](https://docs.digitalocean.com/reference/doctl/how-to/install/) (DigitalOcean CLI)
- DigitalOcean API token
### Setup Instructions
1. Clone this repository
2. Navigate to the `terraform/environments/dev` directory
3. Initialize Terraform:
   \`\`\`
   terraform init
   \`\`\`
4. Apply the Terraform configuration:
   \`\`\`
   terraform apply
   \`\`\`
5. Configure kubectl to use the new cluster:
   \`\`\`
   terraform output -raw kubeconfig > ~/.kube/config
   \`\`\`
6. Deploy ArgoCD:
   \`\`\`
   kubectl apply -f kubernetes/bootstrap/argocd/
   \`\`\`
## Maintenance
### Terraform State
Terraform state is stored locally. Make sure to back up the `terraform.tfstate` file regularly and do not commit it to version control.
### Updating Infrastructure
To make changes to the infrastructure:
1. Modify the appropriate Terraform files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes
## Documentation
See the `docs/` directory for detailed documentation:
- [Architecture Overview](docs/architecture.md)
- [Operations Guide](docs/operations.md)
## License
MIT
