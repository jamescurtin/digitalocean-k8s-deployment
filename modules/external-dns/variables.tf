variable "do_token" {
  description = "DigitalOcean token. Must be R/W."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "external_dns_owner_id" {
  description = "Unique ID used in TXT record created by external-dns (e.g. 7a229b)"
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

variable "bitnami_repository" {
  description = "URL of the Bitnami repo"
  type        = string
  default     = "https://charts.bitnami.com/bitnami"
}
