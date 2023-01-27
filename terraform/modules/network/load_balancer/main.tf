resource "google_compute_url_map" "serverless_lb" {
  name            = "serverless-lb"
  default_service = google_compute_backend_service.global.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "assets"
  }
  path_matcher {
    name            = "assets"
    default_service = google_compute_backend_service.global.id
    path_rule {
      service = var.backend_bucket.id
      paths   = ["/assets/*"]
    }
  }
}

resource "google_compute_target_https_proxy" "serverless_lb_target_proxy" {
  name             = "serverless-lb-target-proxy"
  url_map          = google_compute_url_map.serverless_lb.id
  ssl_certificates = [for ssl_cert in var.ssl_certificates : ssl_cert.id]
  ssl_policy       = var.ssl_policy.id
}
