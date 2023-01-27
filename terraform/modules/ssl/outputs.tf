output "policy" {
  value = google_compute_ssl_policy.main
}

output "certificates" {
  value = [google_compute_managed_ssl_certificate.cert]
}
