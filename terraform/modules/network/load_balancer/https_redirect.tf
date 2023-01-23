resource "google_compute_url_map" "https_redirect" {
  name        = "https-redirect"
  description = "Automatically generated HTTP to HTTPS redirect for the https forwarding rule"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "https_target_proxy" {
  provider = google
  name     = "https-target-proxy"
  url_map  = google_compute_url_map.https_redirect.id
}