#!/bin/bash

# ArgoCD Debugging Steps

# Step 1: Delete the existing ArgoCD deployment
echo "Deleting existing ArgoCD deployment..."
kubectl delete -f k8s/bootstrap/argocd/install.yaml

# Step 2: Wait for all resources to be deleted
echo "Waiting for resources to be deleted..."
kubectl wait --for=delete namespace/argocd --timeout=120s 2>/dev/null || true

# Step 3: Apply the fixed ArgoCD installation
echo "Applying fixed ArgoCD installation..."
kubectl apply -f k8s/bootstrap/argocd/install.yaml

# Step 4: Wait for ArgoCD server deployment to be ready
echo "Waiting for ArgoCD deployment to be ready..."
kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s

# Step 5: Check the status of all ArgoCD pods
echo "Checking ArgoCD pod status..."
kubectl get pods -n argocd

# Step 6: Check if the ArgoCD server is accessible
echo "Checking if ArgoCD server is accessible..."
kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ""

# Step 7: Get the ArgoCD admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Step 8: Deploy the monitoring applications
echo "Deploying monitoring applications..."
kubectl apply -f k8s/apps/monitoring/namespace.yaml
kubectl apply -f k8s/apps/system/argocd-apps.yaml

# Step 9: Check the status of the applications
echo "Checking application status..."
kubectl get applications -n argocd

# Step 10: Check Grafana deployment status
echo "Waiting for Grafana to be deployed (this may take a few minutes)..."
kubectl -n monitoring get pods

echo "Complete! Use the following URL to access ArgoCD:"
echo "http://$(kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "Username: admin"
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
