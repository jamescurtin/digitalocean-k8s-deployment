variable "external_domain" {
  description = "Domain associated with the ingress controller (e.g. example.com)"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "deployment_subdomain" {
  description = "Subdomain on which to serve ntfy."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "timezone" {
  description = "Timezone of the deployment."
  type        = string
  sensitive   = true
  default     = "UTC"
}
