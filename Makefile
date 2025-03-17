# Kubernetes Prototype on DigitalOcean Makefile
# This Makefile provides helper commands for setting up and managing the project

# Variables
ENVIRONMENT ?= dev
TOFU_DIR = tofu
K8S_DIR = k8s
HELM_VALUES_DIR = helm-values

# Check for required binaries
REQUIRED_BINS := tofu kubectl helm doctl

# DigitalOcean API token - should be passed as environment variable
# DO_TOKEN should be set in your environment or passed explicitly

# Colors for better output
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

#* Setup
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help

help: ## list make commands
	@echo ${MAKEFILE_LIST}
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup commands
check-requirements: ## [Setup] Check if required tools are installed
	@echo "${YELLOW}Checking for required tools...${NC}"
	@for bin in $(REQUIRED_BINS); do \
		which $$bin > /dev/null || { echo "${RED}$$bin is not installed. Please install it and try again.${NC}"; exit 1; } && echo "${GREEN}$$bin found${NC}"; \
	done
	@echo "${GREEN}All requirements satisfied.${NC}"

check-token: ## [Setup] Verify DigitalOcean API token is set
	@if [ -z "$(DO_TOKEN)" ]; then \
		echo "${RED}DO_TOKEN environment variable is not set.${NC}"; \
		echo "Please set it with: export DO_TOKEN=your_digitalocean_token"; \
		echo "Or pass it directly: DO_TOKEN=your_token make <command>"; \
		exit 1; \
	fi
	@echo "${GREEN}DigitalOcean token found.${NC}"

setup: check-requirements check-token init apply get-kubeconfig deploy-argocd deploy-monitoring get-endpoints ## [Setup] Full setup - convenience target for initial setup
	@echo "${GREEN}Setup complete!${NC}"
	@echo "ArgoCD and monitoring stack have been deployed."
	@echo "Use 'make get-argocd-password' to get the ArgoCD admin password."
	@echo "Use 'make get-grafana-password' to get the Grafana admin password."

# Infrastructure commands
tofu-init: ## [tofu] initialize terraform
	@bash scripts/init.sh

tofu-apply: ## [tofu] apply terraform
	@bash scripts/apply.sh

tofu-destroy: ## [tofu] destroy terraform
	@bash scripts/destroy.sh

tofu-plan: ## [tofu] plan terraform changes
	@bash scripts/plan.sh

# Kubernetes commands
get-kubeconfig: check-requirements ## [Kubernetes] Get and merge kubeconfig from Terraform output
	@echo "${YELLOW}Getting kubeconfig from Terraform output...${NC}"
	mkdir -p $(HOME)/.kube/config.d
	@echo "${YELLOW}Saving cluster config to $(HOME)/.kube/config.d/config-$(ENVIRONMENT)...${NC}"
	cluster_name=$(cd $(TOFU_DIR) && tofu output -raw cluster_name)
	cd $(TOFU_DIR) && tofu output -raw kubeconfig > $(HOME)/.kube/config.d/config-$(cluster_name)
	chmod 600 $(HOME)/.kube/config.d/config-$(cluster_name)
	@echo "Test with: kubectl get nodes"

deploy-monitoring: check-requirements ## [Kubernetes] Deploy monitoring stack via ArgoCD
	@echo "${YELLOW}Deploying monitoring stack via ArgoCD...${NC}"
	kubectl apply -f $(K8S_DIR)/apps/monitoring/namespace.yaml
	kubectl apply -f $(K8S_DIR)/apps/system/argocd-apps.yaml
	@echo "${GREEN}Monitoring applications deployed to ArgoCD.${NC}"
	@echo "Check status with: kubectl get applications -n argocd"

# Access commands
get-argocd-password: check-requirements ## [Access] Get ArgoCD admin password
	@echo "${YELLOW}Getting ArgoCD admin password...${NC}"
	@echo "Admin Username: admin"
	@echo "Admin Password: $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

get-grafana-password: check-requirements ## [Access] Get Grafana admin password
	@echo "${YELLOW}Getting Grafana admin password...${NC}"
	@echo "Admin Username: admin"
	@echo "Admin Password: $(shell kubectl -n monitoring get secret grafana -o jsonpath="{.data.admin-password}" | base64 -d)"

get-endpoints: check-requirements ## [Access] Get endpoints for ArgoCD and Grafana
	@echo "${YELLOW}Getting service endpoints...${NC}"
	@echo "ArgoCD URL: http://$(shell kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	@echo "Grafana URL: http://$(shell kubectl -n monitoring get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Management commands
backup-state: ## [Management] Backup Terraform state files
	@echo "${YELLOW}Backing up Terraform state...${NC}"
	mkdir -p $(TOFU_DIR)/state-backups
	cp $(TOFU_DIR)/terraform.tfstate $(TOFU_DIR)/state-backups/terraform.tfstate.$(shell date +%Y%m%d-%H%M%S)
	@echo "${GREEN}State backup created at $(TOFU_DIR)/state-backups/${NC}"

destroy: check-requirements check-token ## [Management] Destroy all infrastructure (USE WITH CAUTION)
	@echo "${RED}WARNING: This will destroy all infrastructure. This action is irreversible.${NC}"
	@echo "${RED}Type 'yes' to confirm: ${NC}"
	@read -p "" confirm; \
	if [ "$$confirm" = "yes" ]; then \
		echo "${YELLOW}Destroying infrastructure...${NC}"; \
		cd $(TOFU_DIR) && tofu destroy -auto-approve -var="do_token=$(DO_TOKEN)"; \
		echo "${GREEN}Infrastructure destroyed.${NC}"; \
	else \
		echo "${YELLOW}Destroy canceled.${NC}"; \
	fi

clean: ## [Management] Clean local files
	@echo "${YELLOW}Cleaning local files...${NC}"
	rm -f $(HOME)/.kube/config-$(ENVIRONMENT)
	@echo "${YELLOW}Note: Main ~/.kube/config was preserved. Remove manually if needed.${NC}"
	@echo "${GREEN}Local files cleaned.${NC}"

#* ArgoCD management
argo-install: ## [argocd] install ArgoCD in the cluster
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for ArgoCD pods to be ready..."
	kubectl wait --for=condition=available deployment --all -n argocd --timeout=300s
	@echo "\nArgoCD admin password:"
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

argo-pass: ## [argocd] get ArgoCD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

argo-pf: argo-pass ## [argocd] access ArgoCD UI at http://localhost:8080
	@echo "Access ArgoCD UI at http://localhost:8080 (username admin)"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argo-uninstall: ## [argocd] uninstall ArgoCD from the cluster
	@echo "${YELLOW}Uninstalling ArgoCD from the cluster...${NC}"
	kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl delete namespace argocd
	@echo "${GREEN}ArgoCD has been uninstalled.${NC}"
