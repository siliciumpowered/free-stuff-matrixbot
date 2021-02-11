.DEFAULT_GOAL := help

KUBECONFIG ?= $(shell echo "${KUBECONFIG}")
CHART ?= free-stuff-matrixbot
VERSION ?= 0.0.1
RELEASE ?= free-stuff-matrixbot
VALUES ?= values.yml
SECRETS_ENV_FILE ?= .env
DEBUG ?= --debug
DRYRUN ?=
STORAGE_FILE ?= storage.json

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

.PHONY: shell
shell:
	kubectl create --filename=sleep-pod.yml
	kubectl wait --for=condition=Ready --timeout=180s pod/free-stuff-matrixbot-sleep
	kubectl exec free-stuff-matrixbot-sleep --container=sleep --stdin=true --tty=true -- /sbin/tini -s -- /usr/local/bin/docker-entrypoint.sh shell
	kubectl delete --filename=sleep-pod.yml --wait

.PHONY: upload-storage
upload-storage:
	kubectl create --filename=sleep-pod.yml
	kubectl wait --for=condition=Ready --timeout=180s pod/free-stuff-matrixbot-sleep
	kubectl cp $(STORAGE_FILE) free-stuff-matrixbot-sleep:/srv/free-stuff-matrixbot/storage/storage.json --container=sleep
	kubectl delete --filename=sleep-pod.yml --wait

.PHONY: download-storage
download-storage:
	kubectl create --filename=sleep-pod.yml
	kubectl wait --for=condition=Ready --timeout=180s pod/free-stuff-matrixbot-sleep
	kubectl cp free-stuff-matrixbot-sleep:/srv/free-stuff-matrixbot/storage/storage.json $(STORAGE_FILE) --container=sleep
	kubectl delete --filename=sleep-pod.yml --wait

.PHONY: uninstall
uninstall:
	helm --kubeconfig=$(KUBECONFIG) uninstall $(DEBUG) $(DRYRUN) $(RELEASE)
