#!/bin/bash

#Push to github
docker build -t "docker.pkg.github.com/r26d/doctl-helm-action/doctl-helm-action:v${1}" .
docker build -t "docker.pkg.github.com/r26d/doctl-helm-action/doctl-helm-action:latest" .
docker push "docker.pkg.github.com/r26d/doctl-helm-action/doctl-helm-action:latest"
docker push "docker.pkg.github.com/r26d/doctl-helm-action/doctl-helm-action:v${1}"

##Push to docker
docker build -t "delmendo/doctl-helm-action:v${1}" .
docker build -t delmendo/doctl-helm-action:latest .
docker push delmendo/doctl-helm-action:latest
docker push "delmendo/doctl-helm-action:v${1}"
