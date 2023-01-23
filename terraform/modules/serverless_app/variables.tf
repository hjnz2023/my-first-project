variable "namespace" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_access" {
  type = object({
    connector = any
    egress = optional(string, "all-traffic")
  })
  nullable = true
  default = null
}

variable "service_name" {
  type = string
}