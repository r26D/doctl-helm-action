#!/bin/bash

#Push to github
docker build -t "ghcr.io/r26d/doctl-helm-action/doctl-helm-action:v${1}" .
docker build -t "ghcr.io/r26d/doctl-helm-action/doctl-helm-action:latest" .
docker push "ghcr.io/r26d/doctl-helm-action/doctl-helm-action:latest"
docker push "ghcr.io/r26d/doctl-helm-action/doctl-helm-action:v${1}"

##Push to docker
#docker build -t "delmendo/doctl-helm-action:v${1}" .
#docker build -t delmendo/doctl-helm-action:latest .
#docker push delmendo/doctl-helm-action:latest
#docker push "delmendo/doctl-helm-action:v${1}"
