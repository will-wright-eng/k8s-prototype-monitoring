# Kubernetes Prototype on DigitalOcean Makefile
# This Makefile provides helper commands for setting up and managing the project

# Variables
ENVIRONMENT ?= dev
TOFU_DIR = tofu/environments/$(ENVIRONMENT)
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

.PHONY: check-requirements check-token init plan apply destroy get-kubeconfig deploy-argocd deploy-monitoring get-argocd-password get-grafana-password get-endpoints backup-state help clean

# Default target
help:
	@echo "${YELLOW}Kubernetes Prototype on DigitalOcean - Makefile Help${NC}"
	@echo ""
	@echo "${GREEN}Setup Commands:${NC}"
	@echo "  make check-requirements   - Check if required tools are installed"
	@echo "  make init                 - Initialize Terraform/OpenTofu"
	@echo "  make plan                 - Plan infrastructure changes"
	@echo "  make apply                - Apply infrastructure changes"
	@echo ""
	@echo "${GREEN}Kubernetes Commands:${NC}"
	@echo "  make get-kubeconfig       - Get kubeconfig from Terraform output"
	@echo "  make deploy-argocd        - Deploy ArgoCD to the cluster"
	@echo "  make deploy-monitoring    - Deploy monitoring stack via ArgoCD"
	@echo ""
	@echo "${GREEN}Access Commands:${NC}"
	@echo "  make get-endpoints        - Get endpoints for ArgoCD and Grafana"
	@echo "  make get-argocd-password  - Get initial ArgoCD admin password"
	@echo "  make get-grafana-password - Get Grafana admin password"
	@echo ""
	@echo "${GREEN}Management Commands:${NC}"
	@echo "  make backup-state         - Backup Terraform state files"
	@echo "  make destroy              - Destroy all infrastructure (USE WITH CAUTION)"
	@echo "  make clean                - Clean local files (kubeconfig, etc.)"
	@echo ""
	@echo "${YELLOW}Usage Examples:${NC}"
	@echo "  make init apply deploy-argocd deploy-monitoring get-endpoints"
	@echo "  DO_TOKEN=your_token make apply"

# Check if all required tools are installed
check-requirements:
	@echo "${YELLOW}Checking for required tools...${NC}"
	@for bin in $(REQUIRED_BINS); do \
		which $$bin > /dev/null || { echo "${RED}$$bin is not installed. Please install it and try again.${NC}"; exit 1; } && echo "${GREEN}$$bin found${NC}"; \
	done
	@echo "${GREEN}All requirements satisfied.${NC}"

# Check if DigitalOcean token is set
check-token:
	@if [ -z "$(DO_TOKEN)" ]; then \
		echo "${RED}DO_TOKEN environment variable is not set.${NC}"; \
		echo "Please set it with: export DO_TOKEN=your_digitalocean_token"; \
		echo "Or pass it directly: DO_TOKEN=your_token make <command>"; \
		exit 1; \
	fi
	@echo "${GREEN}DigitalOcean token found.${NC}"

# Initialize OpenTofu/Terraform
init: check-requirements
	@echo "${YELLOW}Initializing Terraform/OpenTofu in $(TOFU_DIR)...${NC}"
	cd $(TOFU_DIR) && tofu init
	@echo "${GREEN}Initialization complete.${NC}"

# Plan infrastructure changes
plan: check-requirements check-token
	@echo "${YELLOW}Planning infrastructure changes...${NC}"
	cd $(TOFU_DIR) && tofu plan -var="do_token=$(DO_TOKEN)"

# Apply infrastructure changes
apply: check-requirements check-token
	@echo "${YELLOW}Applying infrastructure changes...${NC}"
	cd $(TOFU_DIR) && tofu apply -auto-approve -var="do_token=$(DO_TOKEN)"
	@echo "${GREEN}Infrastructure provisioned.${NC}"

# Get kubeconfig from Terraform output
get-kubeconfig: check-requirements
	@echo "${YELLOW}Getting kubeconfig from Terraform output...${NC}"
	mkdir -p $(HOME)/.kube
	@echo "${YELLOW}Saving cluster config to $(HOME)/.kube/config-$(ENVIRONMENT)...${NC}"
	cd $(TOFU_DIR) && tofu output -raw kubeconfig > $(HOME)/.kube/config-$(ENVIRONMENT)
	chmod 600 $(HOME)/.kube/config-$(ENVIRONMENT)
	@echo "${YELLOW}Merging with existing kubeconfig...${NC}"
	KUBECONFIG=$(HOME)/.kube/config:$(HOME)/.kube/config-$(ENVIRONMENT) kubectl config view --flatten > $(HOME)/.kube/config.merged
	mv $(HOME)/.kube/config.merged $(HOME)/.kube/config
	chmod 600 $(HOME)/.kube/config
	@echo "${GREEN}Cluster configuration merged into $(HOME)/.kube/config${NC}"
	@echo "Test with: kubectl get nodes"

# Deploy ArgoCD to the cluster
deploy-argocd: check-requirements
	@echo "${YELLOW}Deploying ArgoCD to the cluster...${NC}"
	kubectl apply -f $(K8S_DIR)/bootstrap/argocd/install.yaml
	@echo "${YELLOW}Waiting for ArgoCD deployment to be ready...${NC}"
	kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s
	@echo "${GREEN}ArgoCD deployed.${NC}"

# Deploy monitoring stack via ArgoCD
deploy-monitoring: check-requirements
	@echo "${YELLOW}Deploying monitoring stack via ArgoCD...${NC}"
	kubectl apply -f $(K8S_DIR)/apps/monitoring/namespace.yaml
	kubectl apply -f $(K8S_DIR)/apps/system/argocd-apps.yaml
	@echo "${GREEN}Monitoring applications deployed to ArgoCD.${NC}"
	@echo "Check status with: kubectl get applications -n argocd"

# Get ArgoCD admin password
get-argocd-password: check-requirements
	@echo "${YELLOW}Getting ArgoCD admin password...${NC}"
	@echo "Admin Username: admin"
	@echo "Admin Password: $(shell kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"

# Get Grafana admin password
get-grafana-password: check-requirements
	@echo "${YELLOW}Getting Grafana admin password...${NC}"
	@echo "Admin Username: admin"
	@echo "Admin Password: $(shell kubectl -n monitoring get secret grafana -o jsonpath="{.data.admin-password}" | base64 -d)"

# Get endpoints for ArgoCD and Grafana
get-endpoints: check-requirements
	@echo "${YELLOW}Getting service endpoints...${NC}"
	@echo "ArgoCD URL: http://$(shell kubectl -n argocd get svc argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
	@echo "Grafana URL: http://$(shell kubectl -n monitoring get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Backup Terraform state
backup-state:
	@echo "${YELLOW}Backing up Terraform state...${NC}"
	mkdir -p $(TOFU_DIR)/state-backups
	cp $(TOFU_DIR)/terraform.tfstate $(TOFU_DIR)/state-backups/terraform.tfstate.$(shell date +%Y%m%d-%H%M%S)
	@echo "${GREEN}State backup created at $(TOFU_DIR)/state-backups/${NC}"

# Destroy all infrastructure - USE WITH CAUTION
destroy: check-requirements check-token
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

# Clean local files
clean:
	@echo "${YELLOW}Cleaning local files...${NC}"
	rm -f $(HOME)/.kube/config-$(ENVIRONMENT)
	@echo "${YELLOW}Note: Main ~/.kube/config was preserved. Remove manually if needed.${NC}"
	@echo "${GREEN}Local files cleaned.${NC}"

# Full setup - convenience target for initial setup
setup: check-requirements check-token init apply get-kubeconfig deploy-argocd deploy-monitoring get-endpoints
	@echo "${GREEN}Setup complete!${NC}"
	@echo "ArgoCD and monitoring stack have been deployed."
	@echo "Use 'make get-argocd-password' to get the ArgoCD admin password."
	@echo "Use 'make get-grafana-password' to get the Grafana admin password."
