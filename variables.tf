##############################
#     Required variables     #
##############################

variable "do_token" {
  description = "DigitalOcean token. Must be R/W."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "external_dns_owner_id" {
  description = "Unique ID used in TXT record created by external-dns (e.g. 7a229b). See https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "external_domain" {
  description = "Domain associated with the ingress controller (e.g. example.com)"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "letsencrypt_email" {
  description = "Email used to provision LetsEncrypt certs"
  type        = string
  sensitive   = true
  nullable    = false
}

##############################
#     Optional variables     #
##############################

variable "region" {
  description = "Digital Ocean datacenter region. Run `doctl kubernetes options regions` for full list."
  type        = string
  default     = "nyc3"
}

variable "loadbalancer_subdomain" {
  description = "A subdomain of the `external_domain` which will point to the public LB. Should not already be in use."
  type        = string
  default     = "kube"
}

variable "node_size" {
  description = "Compute size slug. Run `doctl compute size list` for full list"
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "min_nodes" {
  description = "Minimum number of nodes in the cluster node pool for autoscaling"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes in the cluster node pool for autoscaling"
  type        = number
  default     = 2
}

variable "node_pool_autoscales" {
  description = "If cluster node pool should autoscale"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "If Digital Ocean should automatically upgrade the k8s version on the cluster"
  type        = bool
  default     = true
}

variable "surge_upgrade" {
  description = "If the number of nodes in the cluster can temporarially surge during cluster upgrades"
  type        = bool
  default     = true
}

variable "maintenance_day" {
  description = "Day of week when cluster upgrades should be applied"
  type        = string
  default     = "friday"
}

variable "maintenance_start_time" {
  description = "Time of day when cluster upgrades should be applied"
  type        = string
  default     = "03:00"
}
