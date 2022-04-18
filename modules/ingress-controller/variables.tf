variable "loadbalancer_id" {
  description = "ID of the DigitalOcean loadbalancer to associate with the ingres controller."
  type        = string
  nullable    = false
}

variable "loadbalancer_hostname" {
  description = "The hostname associated with the loadbalancer."
  type        = string
  nullable = false
}

variable "loadbalancer_name" {
    description = "The name of the loadbalancer."
    type = string
    nullable = false
}
