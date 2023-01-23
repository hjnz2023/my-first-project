resource "google_compute_global_address" "main" {
  name = "serverless-lb"
}

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "https"
  target                = google_compute_target_https_proxy.serverless_lb_target_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  ip_address            = google_compute_global_address.main.address
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = "https-forwarding-rule"
  ip_address            = google_compute_global_address.main.address
  port_range            = "80"
  ip_protocol           = "TCP"
  target                = google_compute_target_http_proxy.https_target_proxy.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}