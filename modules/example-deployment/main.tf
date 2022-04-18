terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}

resource "helm_release" "example_deployment" {
  chart     = "${path.module}/charts/example-deployment"
  name      = "example-deployment"
  namespace = "example-deployment"


  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set {
    name  = "hostname"
    value = var.external_domain
  }
  set {
    name  = "subdomain"
    value = var.deployment_subdomain
  }
}
