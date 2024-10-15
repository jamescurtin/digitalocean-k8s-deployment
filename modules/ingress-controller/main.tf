terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.16.1"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"

  cleanup_on_fail  = true
  create_namespace = true
  force_update     = true
  max_history      = 3

  set_sensitive {
    # DO will automatically create a new load balancer if this value is not set
    # or the value doesn't correspond to the ID of an existing LB.
    name  = "controller.service.annotations.kubernetes\\.digitalocean\\.com/load-balancer-id"
    value = var.loadbalancer_id
  }
  set_sensitive {
    # See https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#accessing-by-hostname
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-hostname"
    value = var.loadbalancer_hostname
  }
  set_sensitive {
    # See https://docs.digitalocean.com/products/kubernetes/how-to/configure-load-balancers/#name
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/do-loadbalancer-name"
    value = var.loadbalancer_name
  }

  values = [
    file("${path.module}/values.yaml")
  ]
}
