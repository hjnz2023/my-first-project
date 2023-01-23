locals {
  name = "${var.namespace}-serverless-outbound"
}
resource "google_compute_address" "main" {
  name   = local.name
  region = var.region
}

resource "google_compute_router" "main" {
  name    = local.name
  region  = var.region
  project = var.project_id
  network = var.network_id
}

resource "google_compute_router_nat" "main" {
  name   = local.name
  router = google_compute_router.main.name
  region = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.main.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.main
    content {
      name = subnetwork.value.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
}
