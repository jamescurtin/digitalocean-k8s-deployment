terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "=2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "=2.7.1"
    }
  }
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "digital_ocean_token" {
  metadata {
    name      = "digital-ocean-token"
    namespace = kubernetes_namespace.external_dns.metadata.0.name
    labels = {
      "sensitive" = "true"
    }
  }
  data = {
    "digitalocean_api_token" = var.do_token
  }

  depends_on = [
    kubernetes_namespace.external_dns
  ]
}

resource "helm_release" "external_dns" {
  chart      = "external-dns"
  name       = "external-dns"
  namespace  = "external-dns"
  repository = var.bitnami_repository

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set_sensitive {
    name  = "domainFilters[0]"
    value = var.external_domain
  }
  set_sensitive {
    name  = "txtOwnerId"
    value = var.external_dns_owner_id
  }

  values = [
    file("${path.module}/values.yaml")
  ]

  depends_on = [
    kubernetes_secret.digital_ocean_token,
  ]
}
