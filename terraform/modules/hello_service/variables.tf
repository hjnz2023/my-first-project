variable "namespace" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "deploy_service" {
  type = string
}

variable "port" {
  type = number
}

variable "assets_bucket_name" {
  type = string
}

variable "optional_build_steps" {
  type    = list(string)
  default = []
}
