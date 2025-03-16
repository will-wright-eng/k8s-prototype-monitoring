# Architecture Overview

This document provides a detailed overview of the Kubernetes prototype architecture on DigitalOcean.

## Core Components

The architecture consists of four primary layers:

1. **Infrastructure Layer** (OpenTofu/Terraform + DigitalOcean)
2. **Package Management Layer** (Helm)
3. **Continuous Delivery Layer** (ArgoCD)
4. **Observability Layer** (Grafana, Loki, Promtail)

## Infrastructure Layer

The infrastructure is provisioned using OpenTofu (Terraform compatible) on DigitalOcean's cloud platform:

- **VPC**: Isolated network environment for the cluster
- **Kubernetes Cluster**: DOKS (DigitalOcean Kubernetes Service)
- **Node Pools**:
  - Primary Pool: Application workloads (3 nodes, s-4vcpu-8gb)
  - Monitoring Pool: Observability stack (2 nodes, c-4)
- **Load Balancers**: For exposing services externally

Infrastructure state is stored locally in the terraform.tfstate file, which should be backed up regularly.

## Package Management Layer

Helm is used for package management, providing templated application deployments:

- **Chart Sources**:
  - Official Helm repositories for ArgoCD, Grafana, Loki, and Promtail
- **Custom Values**:
  - Environment-specific configurations in the helm-values directory

## Continuous Delivery Layer

ArgoCD provides GitOps-based continuous delivery:

- **Application Definitions**: Stored in the k8s/apps directory
- **Repository Synchronization**: Automatic sync from Git to cluster
- **App of Apps Pattern**: Used for deploying the monitoring stack

## Observability Layer

The Grafana stack provides comprehensive monitoring and observability:

- **Grafana**: Visualization and dashboarding
- **Loki**: Log aggregation and querying
- **Promtail**: Log collection from Kubernetes nodes and pods

## Network Architecture

- Internal services communicate via Kubernetes service discovery
- External services are exposed via DigitalOcean Load Balancers
- NGINX Ingress Controller (to be added) will handle HTTP/HTTPS routing

## Security Considerations

- VPC isolation for network segmentation
- RBAC for Kubernetes access control
- Node-level security via DigitalOcean features
- Encrypted persistent storage

## Resource Allocation

- **Control Plane**: Managed by DigitalOcean
- **Primary Pool**: Application workloads, 3 nodes x 4 vCPU/8GB RAM
- **Monitoring Pool**: Observability stack, 2 nodes x 4 vCPU optimized

## Scaling Strategy

- Horizontal scaling through additional nodes in node pools
- Application-level scaling through Kubernetes HPA (Horizontal Pod Autoscaler)
