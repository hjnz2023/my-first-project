resource "google_compute_network" "default" {
  name         = "default"
  description  = "Default network for the project"
  project      = var.project_id
  routing_mode = "REGIONAL"
}