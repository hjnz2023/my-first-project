variable "region" {
  type = string
}
variable "service_name" {
  type = string
}

variable "ssl_certificates" {
  type = object({
    id = string
  })
}

variable "ssl_policy" {
  type = object({
    id = string
  })
}

variable "backend_bucket" {
  type = any
}
