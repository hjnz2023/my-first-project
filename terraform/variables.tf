variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "namespace" {
  description = "The project namespace to use for unique resource naming"
  type        = string
}

variable "managed_domains" {
  type = list(string)
}
