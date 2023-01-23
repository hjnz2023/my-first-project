output "policy" {
  value = google_compute_ssl_policy.main
}

output "certificate" {
  value = google_compute_managed_ssl_certificate.main
}