#!/bin/bash
# Debugging script for monitoring stack deployment issues

REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="$REPO_ROOT/scripts"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/common.sh"

echo -e "${YELLOW}=== Debugging Grafana Pod Scheduling Issues ===${NC}"

# Check nodes and their labels
echo -e "\n${YELLOW}Checking cluster nodes and their labels:${NC}"
kubectl get nodes --show-labels

# Check if there are any nodes with the monitoring label
echo -e "\n${YELLOW}Checking for nodes with node-type=monitoring label:${NC}"
kubectl get nodes -l node-type=monitoring

echo -e "\n${YELLOW}Checking current pods in monitoring namespace:${NC}"
kubectl get pods -n monitoring

echo -e "\n${YELLOW}Checking PersistentVolumeClaims:${NC}"
kubectl get pvc -n monitoring

echo -e "\n${YELLOW}Checking ArgoCD applications:${NC}"
kubectl get applications -n argocd

# Check events in the monitoring namespace
echo -e "\n${YELLOW}Recent events in monitoring namespace:${NC}"
kubectl get events -n monitoring --sort-by='.lastTimestamp' | tail -n 20

echo -e "\n${GREEN}=== Debugging Options ===${NC}"
echo -e "1. If no nodes with 'node-type=monitoring' label exist, you have two options:"
echo -e "   a. ${GREEN}Option 1:${NC} Update Helm values to remove node selectors and affinity rules"
echo -e "      - Update helm-values/grafana/values.yaml"
echo -e "      - Update helm-values/loki/values.yaml"
echo -e "      - Update helm-values/promtail/values.yaml"
echo -e "   b. ${GREEN}Option 2:${NC} Add a dedicated monitoring node pool in your Terraform"
echo -e "      - Add monitoring_node_pool resource in tofu/main.tf"
echo -e "      - Run 'make tofu-apply' to create the new node pool"
echo -e "\n2. To update ArgoCD applications with new values:"
echo -e "   kubectl delete application grafana loki promtail -n argocd"
echo -e "   kubectl apply -f k8s/apps/system/argocd-apps.yaml"

echo -e "\n${YELLOW}=== Temporary Fix (Apply immediately) ===${NC}"
echo -e "To force the Grafana pod to schedule on available nodes by removing node affinity requirements:"
echo -e "kubectl patch application grafana -n argocd --type merge -p '{\"spec\":{\"source\":{\"helm\":{\"parameters\":[{\"name\":\"nodeSelector\",\"value\":\"{}\"}]}}}}'"
