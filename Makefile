include .env
export $(shell sed 's/=.*//' .env)

.PHONY: infra-init infra-plan infra-apply infra-destroy

infra-init:
	cd infra && tofu init

infra-plan:
	cd infra && tofu plan

infra-apply:
	cd infra && tofu apply -auto-approve

infra-destroy:
	cd infra && tofu destroy -auto-approve
