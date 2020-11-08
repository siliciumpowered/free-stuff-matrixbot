.DEFAULT_GOAL := help

KUBECONFIG ?= $(shell echo "${KUBECONFIG}")
CHART ?= free-stuff-matrixbot
VERSION ?= 0.0.1
RELEASE ?= free-stuff-matrixbot
VALUES ?= values.yml
SECRETS_ENV_FILE ?= .env
DEBUG ?= --debug
DRYRUN ?=
STORAGE_DUMP_FILE ?= storage.json

## Show available make targets
.PHONY: help
help:
	@echo "$(notdir $(realpath .)) make targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

.PHONY: apply-secret
apply-secret:
	kubectl --kubeconfig=$(KUBECONFIG) create secret generic free-stuff-matrixbot-secrets --from-env-file="$(SECRETS_ENV_FILE)" --dry-run=client --output=yaml | kubectl --kubeconfig=$(KUBECONFIG) apply --filename=- $(DRYRUN)

.PHONY: dry-run
dry-run:
	@make apply DRYRUN='--dry-run'

.PHONY: apply
apply:
	helm --kubeconfig=$(KUBECONFIG) --version=$(VERSION) upgrade --install --reset-values $(DEBUG) $(DRYRUN) --values=$(VALUES) --wait $(RELEASE) $(CHART)

.PHONY: dump-storage
dump-storage: dump-storage-wait-for-pod
	kubectl logs $(shell kubectl get pods --selector=job-name=dump-storage-free-stuff-matrixbot --output=jsonpath='{.items[].metadata.name}') | tail +7 > $(STORAGE_DUMP_FILE)
	kubectl delete --filename=dump-storage-job.yml --wait
	@echo "\nstorage dumped into $(STORAGE_DUMP_FILE)"

# This (sub-)target is needed because $(shell …) is ran on target entry (see the dump-storage target) and the pod needs to exist before it can be found
.PHONY: dump-storage-wait-for-pod
dump-storage-wait-for-pod:
	kubectl create --filename=dump-storage-job.yml
	kubectl wait --for=condition=complete --timeout=90s job/dump-storage-free-stuff-matrixbot

.PHONY: uninstall
uninstall:
	helm --kubeconfig=$(KUBECONFIG) uninstall $(DEBUG) $(DRYRUN) $(RELEASE)
