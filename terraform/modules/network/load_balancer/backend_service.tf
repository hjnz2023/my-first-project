resource "google_compute_region_network_endpoint_group" "main" {
  name                  = "cloudrun-hello"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = var.service_name
  }
}

resource "google_compute_backend_service" "global" {
  name                            = "serverless-backends"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  locality_lb_policy              = "ROUND_ROBIN"
  connection_draining_timeout_sec = 0

  backend {
    group = google_compute_region_network_endpoint_group.main.id
  }
}