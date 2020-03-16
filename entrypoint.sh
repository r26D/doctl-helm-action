#!/bin/sh -l
set -e
#Confirm that there is a Digital Ocean Access Token
#Confirm that there is a cluster name
if [[ -z "${DIGITALOCEAN_ACCESS_TOKEN}"] ]; then
  echo "Token Found"
  else
    echo "DIGITALOCEAN_ACCESS_TOKEN missing!"
    exit 127
fi
if [[ -z "${DIGITALOCEAN_K8S_CLUSTER_NAME}"] ]; then
  echo "Cluster Name Found"
  else
    echo "DIGITALOCEAN_K8S_CLUSTER_NAME missing!"
    exit 127
fi
doctl auth init -t ${DIGITALOCEAN_ACCESS_TOKEN}
doctl kubernetes cluster kubeconfig save ${DIGITALOCEAN_K8S_CLUSTER_NAME}

echo "$1"
eval $1