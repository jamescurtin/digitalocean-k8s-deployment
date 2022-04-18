variable "letsencrypt_email" {
  description = "Email used to provision LetsEncrypt certs"
  type        = string
  sensitive   = true
  nullable    = false
}

variable "jetstack_repository" {
  description = "URL of the Jetstack repo"
  type        = string
  default     = "https://charts.jetstack.io"
}
