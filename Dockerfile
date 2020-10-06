FROM python:3.8.6-alpine

## Prepare docker base dependency
RUN set -euxo pipefail; \
    apk update; \
    apk add --no-cache \
        tini \
        su-exec

## Create user with home = work directory
RUN set -euxo pipefail; \
    addgroup --gid 1001 free-stuff-matrixbot; \
    adduser --home '/opt/free-stuff-matrixbot' --gecos '' --ingroup free-stuff-matrixbot --disabled-password --uid 1001 free-stuff-matrixbot
WORKDIR /opt/free-stuff-matrixbot

## Add entrypoint
COPY ["docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh"]
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["run"]

## Install system dependencies for bot dependencies
RUN set -euxo pipefail; \
    apk update; \
    apk add --no-cache \
        build-base \
        gcc

## Install bot dependencies
COPY requirements.txt .
RUN set -euxo pipefail; \
    pip install --no-cache-dir --requirement requirements.txt

## Install bot
COPY ["free-stuff-matrixbot.py", "./"]
