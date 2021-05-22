.DEFAULT_GOAL := help

CHART ?= free-stuff-matrixbot-pvc
RELEASE ?= free-stuff-matrixbot-pvc
NAMESPACE ?= default
DRYRUN ?=

# Show available make targets
.PHONY: help
help:
	@echo "$(notdir $(realpath .)) make targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: apply
apply:
	helm upgrade \
		--debug \
		--install \
		--reset-values \
		--values=values.yml \
		--namespace=$(NAMESPACE) \
		--wait \
		$(DRYRUN) \
		$(RELEASE) \
		$(CHART)

.PHONY: dry-run
dry-run:
	@make apply DRYRUN='--dry-run'

.PHONY: uninstall
uninstall:
	helm --namespace=$(NAMESPACE) uninstall $(RELEASE)
