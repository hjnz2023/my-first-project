
resource "random_id" "cert" {
  byte_length = 4
  prefix      = "issue-cert-"

  keepers = {
    managed_domains = join(",", var.managed_domains)
  }
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = random_id.cert.hex

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = var.managed_domains
  }
}
