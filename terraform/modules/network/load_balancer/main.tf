resource "google_compute_url_map" "serverless_lb" {
  name            = "serverless-lb"
  default_service = google_compute_backend_service.global.id
}

resource "google_compute_target_https_proxy" "serverless_lb_target_proxy" {
  name             = "serverless-lb-target-proxy"
  url_map          = google_compute_url_map.serverless_lb.id
  ssl_certificates = [var.ssl_certificates.id]
  ssl_policy       = var.ssl_policy.id
}