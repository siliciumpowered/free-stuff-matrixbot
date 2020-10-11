.DEFAULT_GOAL := help

KUBECONFIG ?= $(shell echo "${KUBECONFIG}")
CHART ?= free-stuff-matrixbot
VERSION ?= 0.0.1
RELEASE ?= free-stuff-matrixbot
VALUES ?= values.yml
SECRETS_ENV_FILE ?= .env
DEBUG ?= --debug
DRYRUN ?=

## Show available make targets
.PHONY: help
help:
	@echo "$(notdir $(realpath .)) make targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: apply-secret
apply-secret:
	kubectl --kubeconfig=$(KUBECONFIG) create secret generic free-stuff-matrixbot-secrets --from-env-file="$(SECRETS_ENV_FILE)"

.PHONY: dry-run
dry-run:
	@make apply DRYRUN='--dry-run'

.PHONY: apply
apply:
	helm --kubeconfig=$(KUBECONFIG) --version=$(VERSION) upgrade --install --reset-values $(DEBUG) $(DRYRUN) --values=$(VALUES) --wait $(RELEASE) $(CHART)

.PHONY: uninstall
uninstall:
	helm --kubeconfig=$(KUBECONFIG) uninstall $(DEBUG) $(DRYRUN) $(RELEASE)
