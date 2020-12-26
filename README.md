# terraform-kubernetes-cert-manager
Terraform module which deploys cert-manager to a Kubernetes cluster

# Description

This Terraform module deploys the helm chart [cert-manager](https://github.com/jetstack/cert-manager/tree/master/deploy/charts/cert-manager) which is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources.

You can find more about the cert-manager project on [Github](https://github.com/jetstack/cert-manager) or at [cert-manager.io](https://cert-manager.io/)

# Requirements

- Terraform 0.13+
- Kubernetes Cluster

## How to use

The module makes use of the [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs) which looks for Kubernetes configuration in the following location ```"~/.kube/config"```

### Create a Terraform Configuration
---

Create a new directory

```shell
$ mkdir example-deployment
```

Change into the directory

```shell
$ cd example-deployment
```

Create a file for the configuration code

```shell
$ touch main.tf
```

Paste the following configuration into ```main.tf``` and save it.

```hcl
module "cert_manager" {
  source = "github.com/sculley/terraform-kubernetes-cert-manager"

  replica_count = 2
}
```

Run terraform init

```shell
$ terraform init
```

Run terraform plan

```
$ terraform plan
```

Apply the Terraform configuration

```shell
$ terraform apply
```

# Issuing SSL Certificates

By default the module will just install the cert-manager helm chart, its up to you to decide on what kind of Certificate Issuer you want to configure, cert-manager provides many ways of achieving this but most likely you want to use LetsEncrypt. cert-manager provides two methods to verify you own the domain;

- HTTP01
- DNS01

## HTTP01

HTTP01 domain validation requires some work to set, mainly because your pods will need inbound access from the internet for LetsEncrypt to acesss and validate your pod, this can be achieve using [Kubernetes ingress objects](https://kubernetes.io/docs/concepts/services-networking/ingress/).

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: user@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: example-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

You will need to configure an Ingress object to your application to allow LetsEncrypt to be able to access your pod/containers to verify you own the domain using HTTP01.

## DNS01

```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: example-issuer
spec:
  acme:
    email: user@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: example-issuer-account-key
    solvers:
    - dns01:
        cloudDNS:
          project: my-project
          serviceAccountSecretRef:
            name: prod-clouddns-svc-acct-secret
            key: service-account.json
```

Using DNS01 is by far the most easiest way to validate you own a domain if your pods won't have inbound internet access, cert-manager provides [guides](https://cert-manager.io/docs/configuration/acme/dns01/) for many DNS providors