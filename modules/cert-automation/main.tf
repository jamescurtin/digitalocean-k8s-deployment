terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
  }
}

resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = var.jetstack_repository

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set {
    name  = "createCustomResource"
    value = "true"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [
    file("${path.module}/values.yaml")
  ]
}

resource "helm_release" "cluster_issuer" {
  chart     = "${path.module}/charts/cert-automation"
  name      = "cluster-issuer"
  namespace = "cert-manager"

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set_sensitive {
    name  = "letsencrypt_email"
    value = var.letsencrypt_email
  }

  depends_on = [
    helm_release.cert_manager,
  ]
}
