variable "namespace" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "network_id" {
  type = string
}

variable "vpc_access_connectors" {
  type = list(object({
    name = string
    subnetwork = object({
      name          = string
      ip_cidr_range = string
    })
  }))
}
