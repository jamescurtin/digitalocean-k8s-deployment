variable "external_domain" {
  description = "Domain associated with the ingress controller (e.g. example.com)"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "deployment_subdomain" {
  description = "Subdomain on which to serve the hello world example."
  type        = string
  default     = "hello-world"
}
