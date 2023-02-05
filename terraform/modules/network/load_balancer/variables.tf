variable "region" {
  type = string
}
variable "service_name" {
  type = string
}

variable "ssl_certificates" {
  type = list(object({
    id = string
  }))
}

variable "backend_bucket" {
  type = any
}
