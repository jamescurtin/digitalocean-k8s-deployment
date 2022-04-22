provider "digitalocean" {
  token = var.do_token
}

provider "helm" {
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.this.endpoint
    token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = digitalocean_kubernetes_cluster.this.endpoint
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
  load_config_file       = false
}

provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.this.endpoint
  token                  = digitalocean_kubernetes_cluster.this.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "random" {}
