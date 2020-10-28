# doctl-helm-action

This action allows you to talk to DigitalOcean's doctl. It also includes helm and helm secrets support.


## Inputs

### env

####  DIGITALOCEAN_ACCESS_TOKEN
** REQUIRED **  - This is the access token [[https://www.digitalocean.com/docs/apis-clis/api/create-personal-access-token/]]
It is required to talk to Digital Ocean

#### DIGITALOCEAN_K8S_CLUSTER_NAME
** REQUIRED ** - this specifies whick kubernetes cluster the command should be used.

#### DIGITALOCEAN_K8S_NAMESPACE
Optional - if left blank - the actions will happen in the "default" context.  If you set a namespace
a new context will be created with the namespace and used for all helm operations (Helm 3 cares about the
context namespace for some operations)


### SECRETS_GPG_KEY
Optional - this is the private key used to encrypt any secrets in the project.  If you aren't using
helm secrets - then you don't have to set this.

### SECRETS_GPG_PASSPHRASE
Optional - this is the passphrase used on the gpg private key. If you aren't providing a GPG key or if
it doesn't have a passphrase you don't have to set this.


### with

#### working directory 
Optional - This is where the command will be run from
#### cmd
** Required ** - This is the command you want run. 


## Example usage

```yaml
      - name: Helm Process
        uses: r26d/doctl-helm-action@v1.10.0
        env:
          DIGITALOCEAN_ACCESS_TOKEN: ${{ secrets.DIGITALOCEAN_ACCESS_TOKEN }}
          DIGITALOCEAN_K8S_CLUSTER_NAME: ${{ secrets.DIGITALOCEAN_K8S_CLUSTER}}
          SECRETS_GPG_KEY: ${{ secrets.SECRETS_GPG_KEY}}
          SECRETS_GPG_PASSPHRASE: ${{ secrets.SECRETS_GPG_PASSPHRASE}}
        with:
          working_directory: /github/workspace/k8s
          cmd: helm secrets upgrade --install  prod_values.yaml  prod my_chart
  
```
