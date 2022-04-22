terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

resource "helm_release" "gatekeeper" {
  chart      = "gatekeeper"
  name       = "gatekeeper"
  namespace  = "gatekeeper-system"
  repository = var.gatekeeper_repository

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  values = [
    file("${path.module}/values.yaml")
  ]
}

# Requires Ingress resources to be HTTPS only.
resource "kubectl_manifest" "httpsonly_template" {
  yaml_body = data.http.httpsonly_template.body

  depends_on = [
    helm_release.gatekeeper,
  ]
}

resource "kubectl_manifest" "httpsonly_constraint" {
  yaml_body = data.http.httpsonly_constraint.body

  depends_on = [
    kubectl_manifest.httpsonly_template,
  ]
}

# Requires all Ingress rule hosts to be unique.
# Ingress resources must:
#       - include a valid TLS configuration
#       - include the `kubernetes.io/ingress.allow-http` annotation, set to
#         `false`.
resource "kubectl_manifest" "uniqueingresshost_template" {
  yaml_body = data.http.uniqueingresshost_template.body

  depends_on = [
    helm_release.gatekeeper,
  ]
}
resource "kubectl_manifest" "uniqueingresshost_constraint" {
  yaml_body = data.http.uniqueingresshost_constraint.body

  depends_on = [
    kubectl_manifest.uniqueingresshost_template,
  ]
}
