resource "google_compute_subnetwork" "main" {
  for_each = {
    for connector in var.vpc_access_connectors : connector.subnetwork.name => connector.subnetwork
  }
  name                     = each.key
  ip_cidr_range            = each.value.ip_cidr_range
  network                  = var.network_id
  region                   = var.region
  private_ip_google_access = false
  log_config {
    aggregation_interval = "INTERVAL_15_MIN"
    flow_sampling = 1
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_vpc_access_connector" "main" {
  for_each = {
    for connector in var.vpc_access_connectors : connector.name => connector
  }
  name = each.value.name

  subnet {
    name = google_compute_subnetwork.main[each.value.subnetwork.name].name
  }

  # depends_on = [
  #   google_project_service.enabled_service["vpcaccess.googleapis.com"]
  # ]
}
