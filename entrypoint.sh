#!/bin/bash -l
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
if [[ -z "${DIGITALOCEAN_K8S_NAMESPACE}" ]]; then
  DIGITALOCEAN_K8S_NAMESPACE="default"
fi

if [[ -z "${SECRETS_GPG_KEY}" ]]; then
  echo "NO GPG key provided for secrets"
else
  echo 'Importing a gpg key for secrets'
  echo "${SECRETS_GPG_KEY}" >/tmp/private.key
  if [[ -z "${SECRETS_GPG_PASSPHRASE}" ]]; then
    gpg --import /tmp/private.key
  else
    #https://github.com/mozilla/sops/issues/370
    #Sops needs the key loaded into the gpg agent with the password already sorted
    echo "${SECRETS_GPG_PASSPHRASE}" | gpg --batch --import /tmp/private.key
    echo "${SECRETS_GPG_PASSPHRASE}" > /tmp/private_passphrase.txt
    touch /tmp/dummy.txt
    echo "Importing with passphrase"
    gpg --batch --yes --passphrase-file /tmp/private_passphrase.txt --pinentry-mode=loopback -s /tmp/dummy.txt
    rm -f /tmp/dummy.txt /tmp/private_passphrase.txt
  fi
  rm -f /tmp/private.key
fi

doctl auth init -t ${DIGITALOCEAN_ACCESS_TOKEN}
doctl kubernetes cluster kubeconfig save ${DIGITALOCEAN_K8S_CLUSTER_NAME}

if [[ -z "${DIGITALOCEAN_K8S_NAMESPACE}" ]]; then
  echo "Working in the default namespace"
else
  CURRENT_CONTEXT=$(kubectl config current-context)
  kubectl config set-context --current --namespace=${DIGITALOCEAN_K8S_NAMESPACE}
  kubectl config use-context ${CURRENT_CONTEXT}
  echo "Working on the  ${DIGITALOCEAN_K8S_NAMESPACE} namespace"

fi
#Forcing the plugin to load
#Forcing the plugin to load
if $(helm plugin list) | grep -q "secrets"; then
    echo "secrets already plugin installed"
else
  helm plugin install https://github.com/futuresimple/helm-secrets
fi

kubectl version
helm version
helm plugin list

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
