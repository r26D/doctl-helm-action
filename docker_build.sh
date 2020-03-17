#!/bin/bash

docker build -t "delmendo/doctl-helm-action:v${1}" .
docker build -t delmendo/doctl-helm-action:latest .
docker push delmendo/doctl-helm-action:latest
docker push "delmendo/doctl-helm-action:v${1}"
