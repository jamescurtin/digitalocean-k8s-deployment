terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "=2.8.0"
    }
  }
}

resource "helm_release" "nfty" {
  chart     = "${path.module}/charts/ntfy"
  name      = "ntfy"
  namespace = "ntfy"


  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set_sensitive {
    name  = "hostname"
    value = var.external_domain
  }
  set_sensitive {
    name  = "timezone"
    value = var.timezone
  }
  set_sensitive {
    name  = "subdomain"
    value = var.deployment_subdomain
  }
}
