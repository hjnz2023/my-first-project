output "ingress_address" {
  value = google_compute_global_address.main
}

output "neg" {
  value = google_compute_region_network_endpoint_group.main
}

output "serverless-lb" {
  value = google_compute_url_map.serverless_lb
}