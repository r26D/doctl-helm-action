#This docker file was based on one from LICENSE.DavidTesar
FROM alpine:3.18

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
# THe version used at Digital Ocean lags - 
# It can be found at https://www.digitalocean.com/docs/kubernetes/changelog/
ENV DO_KUBE_VERSION="v1.16.9"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.13.2"
#Latest verson of doctl can be found at:
#https://github.com/digitalocean/doctl/releases
ENV DOCTL_VERSION="1.100.0"
# Sops is used to handle the decryption of secrets by helm secerts
#Version can be found at
#https://github.com/mozilla/sops/releases
ENV SOPS_VERSION="3.8.1"
#https://github.com/jkroepke/helm-secrets
ENV HELM_SECRETS_VERSION="4.5.1"
#https://github.com/Praqma/helmsman/issues/518#issuecomment-1151581275
#The PLUGINS directory gets unset and breaks the scripts later
ENV HELM_PLUGINS="/root/.local/share/helm/plugins"


RUN apk add --no-cache ca-certificates bash git openssh curl gnupg && \
    apk add --no-cache --upgrade grep

#Helm and Kubernetes
#Kubectl  was having network problems - so moved it into the repo
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${DO_KUBE_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
RUN wget -q https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64 -O /usr/local/bin/sops \
    && chmod +x /usr/local/bin/sops
#COPY kubectl.${DO_KUBE_VERSION} /usr/local/bin/kubectl
#RUN chmod +x /usr/local/bin/kubectl
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm

#Doctl - based on work by Aron Wolf
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
  curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar xz && \
  cp doctl /bin/
# Add in helm secrets
RUN /usr/local/bin/helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION}


#WORKDIR /config
COPY sops_test_files /sops_test_files
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
