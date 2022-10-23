terraform {
  cloud {
    organization = "jameswcurtin"
    workspaces {
      tags = ["digitalocean", "kubernetes"]
    }
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "=2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.7.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "=1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "= 3.4.3"
    }
  }
}

resource "random_id" "cluster_id" {
  byte_length = 4
}

# Loadbalancer must be created before k8s cluster. If the k8s cluster is created
# first, it dynamically generates a LB and terraform is unable to access the IP.
resource "digitalocean_loadbalancer" "this" {
  name                  = "lb-${var.region}-${random_id.cluster_id.hex}"
  region                = var.region
  enable_proxy_protocol = true

  forwarding_rule {
    entry_port      = 80
    entry_protocol  = "http"
    target_port     = 80
    target_protocol = "http"
  }

  # The forwarding rules defined here are a placeholder, as they will be dynamically
  # set once the k8s cluster is created. Therefore, changes made outside of TF should be ignored
  lifecycle {
    ignore_changes = [
      forwarding_rule,
    ]
  }
}

resource "digitalocean_kubernetes_cluster" "this" {
  name          = "k8s-${var.region}-${random_id.cluster_id.hex}"
  region        = var.region
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  version       = data.digitalocean_kubernetes_versions.do_k8s_versions.latest_version

  maintenance_policy {
    start_time = var.maintenance_start_time
    day        = var.maintenance_day
  }

  node_pool {
    name       = "worker-pool"
    size       = var.node_size
    auto_scale = var.node_pool_autoscales
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }

  depends_on = [
    digitalocean_loadbalancer.this
  ]
  # Ignoring version, which is auto-upgraded by the cluster.
  lifecycle {
    ignore_changes = [
      version,
    ]
  }
}

# Due to k8s limitation, pods cannot communicate via the IP of an external LB.
# Therefore, need to define an A record associated with the LP to allow for
# pod-to-pod communication (in this case necessary for cert-manager)
# See https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#accessing-by-hostname
resource "digitalocean_record" "loadbalancer_subdomain" {
  domain = var.external_domain
  type   = "A"
  name   = var.loadbalancer_subdomain
  value  = digitalocean_loadbalancer.this.ip
  ttl    = 60

  depends_on = [
    digitalocean_loadbalancer.this
  ]
}

module "ingress_controller" {
  source = "./modules/ingress-controller"

  loadbalancer_hostname = "${var.loadbalancer_subdomain}.${var.external_domain}"
  loadbalancer_id       = digitalocean_loadbalancer.this.id
  loadbalancer_name     = "lb-${var.region}-${random_id.cluster_id.hex}"
}

module "external_dns" {
  source = "./modules/external-dns"

  do_token              = var.do_token
  external_dns_owner_id = var.external_dns_owner_id
  external_domain       = var.external_domain

  depends_on = [
    module.ingress_controller,
  ]
}

module "cert_automation" {
  source = "./modules/cert-automation"

  letsencrypt_email = var.letsencrypt_email

  depends_on = [
    module.ingress_controller,
  ]
}

module "gatekeeper" {
  source = "./modules/gatekeeper"
}

# Uncomment for an example of the DNS record and TLS cert automation in action

# module "example_deployment" {
#   source = "./modules/example-deployment"

#   external_domain = var.external_domain

#   depends_on = [
#     module.external_dns,
#     module.cert_automation,
#   ]
# }
