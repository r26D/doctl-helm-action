#This docker file was based on one from LICENSE.DavidTesar
FROM alpine:3.11

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.17.4"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.1.2"
#Latest verson of doctl can be found at:
#https://github.com/digitalocean/doctl/releases
ENV DOCTL_VERSION="1.38.0"

RUN apk add --no-cache ca-certificates bash git openssh curl

#Helm and Kubernetes
#Kubectl  was having network problems - so moved it into the repo
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl
#COPY kubectl.${KUBE_LATEST_VERSION} /usr/local/bin/kubectl
#RUN chmod +x /usr/local/bin/kubectl
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm
#Doctl - based on work by Aron Wolf
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 && \
  curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz  | tar xz && \
  cp doctl /bin/

#WORKDIR /config

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]