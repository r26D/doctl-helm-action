#!/bin/sh -l
set -e
#Confirm that there is a Digital Ocean Access Token
#Confirm that there is a cluster name
if [[ -z "${DIGITALOCEAN_ACCESS_TOKEN}" ]]; then
    echo "DIGITALOCEAN_ACCESS_TOKEN missing!"
    exit 127
fi
if [[ -z "${DIGITALOCEAN_K8S_CLUSTER_NAME}" ]]; then
     echo "DIGITALOCEAN_K8S_CLUSTER_NAME missing!"
    exit 127
fi

doctl auth init -t ${DIGITALOCEAN_ACCESS_TOKEN}
doctl kubernetes cluster kubeconfig save ${DIGITALOCEAN_K8S_CLUSTER_NAME}
if [[ -z "${2}" ]]; then
  echo ""
else
  cd $2
fi
echo "The second argument was ${2}"
PWD=$(pwd)
echo "Working Dir: ${PWD}"
echo "$1"
eval $1