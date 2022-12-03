# Deploy Kubernetes to DigitalOcean with Terraform

[![Continuous Deployment](https://github.com/jamescurtin/digitalocean-k8s-deployment/actions/workflows/terraform.yaml/badge.svg)](https://github.com/jamescurtin/digitalocean-k8s-deployment/actions/workflows/terraform.yaml)
[![Linting](https://github.com/jamescurtin/digitalocean-k8s-deployment/actions/workflows/lint.yaml/badge.svg)](https://github.com/jamescurtin/digitalocean-k8s-deployment/actions/workflows/lint.yaml)

[![DigitalOcean Referral Badge](https://web-platforms.sfo2.digitaloceanspaces.com/WWW/Badge%202.svg)](https://www.digitalocean.com/?refcode=672862fab7f2)

Provision a Kubernetes cluster in DigitalOcean via Terraform.
By default, the k8s cluster deploys come with:

* [Ingress Nginx](https://kubernetes.github.io/ingress-nginx)
* [Cert Manager](https://github.com/cert-manager/cert-manager) (Automatically provision and manage TLS certificates)
* [External DNS](https://github.com/bitnami/charts/tree/master/bitnami/external-dns) (automates the creation of CNAME records when new services are deployed)
* [Gatekeeper](https://open-policy-agent.github.io/gatekeeper/website/docs/)

The following optional services are deployed and should be removed from `main.tf` if they are not desired.

* [Ntfy](https://ntfy.sh/) (Simple pub/sub based notification service)

The project is configured to be run using [Terraform Cloud](https://app.terraform.io/), and plans/applies are conducted remotely.

## First time setup

This project can be cloned and used as-is, except that the value of `terraform.cloud.organization` in `main.tf` will need to be changed to reflect your own [organization](https://www.terraform.io/cloud-docs/users-teams-organizations/organizations).

1. Create a [Digital Ocean account](https://m.do.co/c/672862fab7f2)
1. Create a [Terraform Cloud account](https://app.terraform.io/signup/account)
1. Obtain a domain and [create NS records pointing to DigitalOcean's name servers](https://docs.digitalocean.com/tutorials/dns-registrars/)
1. Install CLI tools:
   * [`doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/)
   * [`terraform`](https://learn.hashicorp.com/tutorials/terraform/install-cli)
   * [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl)
1. [Create a R/W DigitalOcean token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)

   For security, you can set the token to expire, but it will need to be manually rotated. This token will be used in the next step.

1. Connect to Terraform Cloud

    ```bash
    terraform login
    terraform init
    terraform plan
    ```

1. The first time you run `terraform plan`, you will be prompted to set values for certain variables from the CLI. At this point, a workspace will have been created in your Terraform organization for this project. To ensure future Terraform executions happen remotely, navigate to the Terraform Cloud workspace associated with this project and:
    1. On the `Variables` tab, add a "Workspace variable" for each of the required properties defined below.
    1. On the `Settings` -> `General` tab, ensure that:
       * "Execution Mode" is set to "Remote"
       * "Apply Method" is set to "Auto Apply"
1. Enable Continuous Deployment via Github
   * Create a [Terraform Cloud token](https://app.terraform.io/app/settings/tokens)
   * In your Github repo, go to `Settings` -> `Secrets` -> `Actions`. Create a new repository secret called `TF_API_TOKEN` using the token value obtained in the previous step.

## Creating the k8s cluster

To create the k8s cluster for the first time (or to apply changes), just run

```bash
terraform apply
```

Assuming none of the default values have been changed, this will provision:

* A 1-node Kubernetes cluster that can autoscale up to two nodes (Each node has 1 vCPU and 2GB RAM)
  * At time of writing, this would cost between $10-$20/month for one or two nodes, respectively
* A small load balancer that serves all traffic for the cluster
  * At time of writing, this costs $10/month

Once the terraform plan has been applied, you can update your `kubectl` config to connect to the new cluster by default by executing the following:

```bash
CLUSTER_NAME=$(terraform output --raw cluster_name)
doctl kubernetes cluster kubeconfig save "${CLUSTER_NAME}"
```

## Parameters

See `variables.tf`

## Using external-dns and cert-automation

This cluster comes with automated DNS record creation and TLS cert automation.
Using this functionality requires that specific annotations be set on the deployment's ingress.
The Helm chart contained within the `example-deployment` module provides an example of what these annotations look like.

## Using Gatekeeper

Gatekeeper is used as an admission controller on the cluster.
A few basic rules from the [OPA Policy Library](https://github.com/open-policy-agent/gatekeeper-librar) are applied by default

## Limitations / Caveats

* When a new service is deployed, there is a race condition between the creation of a DNS entry (`external-dns`) and the HTTP challenge required to create a TLS certificate (`cert-manager`). This results in cert-manager attempting to resolve the DNS before it propagates, receiving a `NXDOMAIN` response, then needing to wait for the record's TTL to expire before re-trying the challenge. You can read more about the issue [here](https://github.com/cert-manager/cert-manager/issues/4246). To reliably avoid this issue, manually create the DNS entry in Digital Ocean long enough before deploying the corresponding service so that the record has time to propagate.


## Development

Install [`dagger-cue`](https://docs.dagger.io/sdk/cue/526369/install) to run the local CI pipeline.
Dagger depends on Docker engine.

To make sure dependencies are up to date:

```bash
dagger-cue project update
```

To run the lint suite:

```bash
dagger-cue do lint
```

If linting fails, many style guidelines can be automatically applied by:

```bash
dagger-cue do fix
```

`dagger-cue` may take a long time the first time it runs, as it must build docker images.
You can increase the output verbosity to observe the build progress with the flag `--log-format plain`
