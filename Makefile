include .env
export $(shell sed 's/=.*//' .env)

# Tenancy OCID used by audit targets
TENANCY_OCID := ocid1.tenancy.oc1..aaaaaaaawbm2bh6yis76zb2s5r5jwt2ggn3zfehchtz3shzvtbj4zth3mhsq

.PHONY: infra-init infra-plan infra-apply infra-destroy infra-test infra-check costs

infra-init:
	cd infra && tofu init

infra-plan:
	cd infra && tofu plan

infra-apply:
	cd infra && tofu apply -auto-approve

infra-destroy:
	cd infra && tofu destroy -auto-approve

infra-test:
	cd infra && tofu test

# Audit all running compute instances and their shapes
infra-check:
	@echo "--- Running Compute Instances ---"
	@oci compute instance list \
		--compartment-id $(TENANCY_OCID) \
		--all \
		--query "data[*].{Name: \"display-name\", State: \"lifecycle-state\", Shape: shape, Created: \"time-created\"}" \
		--output table
	@echo ""
	@echo "--- Instance Public IPs ---"
	@oci compute instance list \
		--compartment-id $(TENANCY_OCID) --all \
		--query "data[*].id" --raw-output 2>/dev/null | \
		tr -d '[]"' | tr ',' '\n' | xargs -I{} \
		oci compute instance list-vnics --instance-id {} \
		--query "data[*].{PublicIP: \"public-ip\", PrivateIP: \"private-ip\", State: \"lifecycle-state\"}" \
		--output table
	@echo ""
	@echo "--- Boot Volumes ---"
	@oci bv boot-volume list \
		--compartment-id $(TENANCY_OCID) \
		--availability-domain JdwO:US-CHICAGO-1-AD-1 \
		--all \
		--query "data[*].{Name: \"display-name\", SizeGB: \"size-in-gbs\", State: \"lifecycle-state\"}" \
		--output table
	@echo ""
	@echo "--- Additional Block Volumes ---"
	@oci bv volume list \
		--compartment-id $(TENANCY_OCID) \
		--all \
		--query "data[*].{Name: \"display-name\", SizeGB: \"size-in-gbs\", State: \"lifecycle-state\"}" \
		--output table 2>/dev/null || echo "None."
	@echo ""
	@echo "--- Reserved Public IPs (billed if unattached) ---"
	@oci network public-ip list \
		--compartment-id $(TENANCY_OCID) \
		--scope REGION \
		--all \
		--query "data[*].{Name: \"display-name\", IP: \"ip-address\", State: \"lifecycle-state\"}" \
		--output table 2>/dev/null || echo "None."

# ARM Compute Limits (Free Tier)
costs:
	@echo "--- Active Budgets ---"
	@oci budgets budget budget list \
		--compartment-id $(TENANCY_OCID) \
		--all \
		--query "data[*].{Name: \"display-name\", AmountUSD: amount, SpentUSD: \"actual-spend\", State: \"lifecycle-state\"}" \
		--output table 2>/dev/null || echo "No budgets configured. Run 'make infra-apply' to provision one."
	@echo ""
	@echo "--- ARM Compute Limits (Free Tier: 4 OCPU / 24 GB) ---"
	@oci limits value list \
		--compartment-id $(TENANCY_OCID) \
		--service-name compute \
		--availability-domain JdwO:US-CHICAGO-1-AD-1 \
		--query "data[?contains(name, 'standard-a1') && !contains(name, 'reserv') && !contains(name, 'dvh') && !contains(name, 'regional')].{Resource: name, Limit: value}" \
		--all \
		--output table 2>/dev/null || echo "Unable to fetch limits."

# --- Operational Helpers ---

# Get the public IP of the gateway instance (filtered for RUNNING state)
GATEWAY_IP := $(shell oci compute instance list --compartment-id $(TENANCY_OCID) --all --query "data[?\"display-name\"=='openclaw-gateway' && \"lifecycle-state\"=='RUNNING'].id" --raw-output 2>/dev/null | tr -d '[]"\n ' | xargs -I{} oci compute instance list-vnics --instance-id {} --query "data[0].\"public-ip\"" --raw-output 2>/dev/null)

infra-ssh:
	@if [ -z "$(GATEWAY_IP)" ]; then echo "Gateway IP not found. Is the instance running?"; exit 1; fi
	ssh -i ~/.ssh/openclaw_rsa ubuntu@$(GATEWAY_IP)

# Deploy the Cloudflare tunnel token (assumes it exists at ~/.openclaw/tunnel_token locally)
deploy-token:
	@if [ -z "$(GATEWAY_IP)" ]; then echo "Gateway IP not found."; exit 1; fi
	@if [ ! -f ~/.openclaw/tunnel_token ]; then echo "Error: ~/.openclaw/tunnel_token not found on your Mac. Please create it first."; exit 1; fi
	ssh -i ~/.ssh/openclaw_rsa ubuntu@$(GATEWAY_IP) "mkdir -p ~/.openclaw"
	scp -i ~/.ssh/openclaw_rsa ~/.openclaw/tunnel_token ubuntu@$(GATEWAY_IP):~/.openclaw/tunnel_token
	ssh -i ~/.ssh/openclaw_rsa ubuntu@$(GATEWAY_IP) "systemctl --user restart cloudflared.service"
	@echo "Tunnel token deployed and cloudflared restarted."

