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
     echo "Private Key Provided - but not able to decrypt because SECRETS_GPG_PASSPHRASE isn't set"
     exit 127
   # gpg --import /tmp/private.key
  else
    #https://github.com/mozilla/sops/issues/370
    #Sops needs the key loaded into the gpg agent with the password already sorted
    echo "${SECRETS_GPG_PASSPHRASE}" > /tmp/private_passphrase.txt
    #Auto Trusting
    #https://stackoverflow.com/a/70495250
    KEY_ID=$(gpg --list-packets /tmp/private.key | awk '/keyid:/{ print $2 }' | head -1)
    echo "${SECRETS_GPG_PASSPHRASE}" | gpg --batch --import /tmp/private.key
    (echo trust &echo 5 &echo y &echo quit) | gpg --command-fd 0 --edit-key $KEY_ID
    gpg --update-trustdb

    date > /tmp/dummy.txt
    echo "Importing with passphrase"
    gpg --batch --yes --passphrase-file /tmp/private_passphrase.txt --pinentry-mode=loopback -s /tmp/dummy.txt
    

    gpg --output dummy.txt.dec --decrypt dummy.txt.gpg
    if cmp --silent -- "/tmp/dummy.txt" "/tmp/dummy.txt.dec"; then
      echo "Successfully able to decrypt"
    else
         echo "Unable to use the key & passphrase to decrypt data"
         exit 127
    fi
    rm -f /tmp/dummy.txt /tmp/dummy.txt.gpg /tmp/dummy.text.dec /tmp/private_passphrase.txt



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
echo "=== K8s Environment ==="
kubectl version
echo "Helm Version"
helm version
echo "Plugins"
helm plugin list

echo "The second argument was ${2}"
PWD=$(pwd)
echo "Working Dir: ${PWD}"
#Forcing the plugin to load
OUTPUT=$(helm plugin list)
if echo "${OUTPUT}" | grep -q "secrets"; then
    echo "secrets already plugin installed"
else
 # This should be covered by the Dockerfile
 echo "Need to install helm secrets for this to work"
 exit 1
fi

if [[ -z "${2}" ]]; then
  echo ""
else
  cd $2
fi
#https://www.baeldung.com/linux/shell-retry-failed-command

max_iteration="${INPUT_NUMBER_OF_RETRIES:-3}"
helm_timeout="${INPUT_HELM_TIMEOUT:-120}"
for i in $(seq 1 $max_iteration)
do
  echo "$1"
  echo "Attempt ${i}"
  timeout $helm_timeout eval $1
  result=$?
  if [[ $result -eq 0 ]]
  then
    echo "Result successful"
    break
  else
    echo "Result unsuccessful"
    echo "Sleeping for 30 seconds"
    sleep 30
  fi
done

if [[ $result -ne 0 ]]
then
  echo "All of the attempts  failed!!!"
  exit 127
fi



