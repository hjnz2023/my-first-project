resource "google_compute_ssl_policy" "main" {
  name            = "tls1-2-modern"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

# resource "random_id" "certificate" {
#   byte_length = 4
#   prefix      = "issue-cert-"

#   keepers = {
#     managed_domains = join(",", local.managed_domains)
#   }
# }

resource "google_compute_managed_ssl_certificate" "main" {
  #   name = random_id.certificate.hex
  name = var.namespace

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.managed_domains
  }
}