locals {
  services = [
    "domains.googleapis.com",
    "dns.googleapis.com",
    "certificatemanager.googleapis.com",

    "vpcaccess.googleapis.com",

    "compute.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",

    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "enabled_service" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.key

  provisioner "local-exec" {
    command = "sleep 60"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 15"
  }
}

module "hello_service" {
  source             = "./modules/hello_service"
  project_id         = var.project_id
  namespace          = var.namespace
  region             = var.region
  deploy_service     = module.serverless_app.service.name
  port               = 4000
  assets_bucket_name = "dist-apps-hello-browser"
}

module "assets" {
  source = "./modules/assets"
  region = var.region
  name   = "dist-apps-hello-browser"
}

module "serverless_outbound" {
  count      = 0
  source     = "./modules/network/serverless_outbound"
  project_id = var.project_id
  namespace  = var.namespace
  network_id = google_compute_network.default.id
  region     = var.region
  vpc_access_connectors = [
    { name = "cloudrun", subnetwork = { name = "cloudrun", ip_cidr_range = "10.124.0.0/28" } },
    { name = "cloudrun-blue", subnetwork = { name = "cloudrun-blue", ip_cidr_range = "10.125.0.0/28" } }
  ]
}

module "serverless_app" {
  source       = "./modules/serverless_app"
  project_id   = var.project_id
  namespace    = var.namespace
  region       = var.region
  service_name = "hello"
  # vpc_access   = { connector = module.serverless_outbound[0].vpc_access_connectors["cloudrun"] }
}

module "ssl" {
  source          = "./modules/ssl"
  managed_domains = var.managed_domains
  namespace       = var.managed_ssl_cert_name
}

module "load_balancer" {
  source           = "./modules/network/load_balancer"
  region           = var.region
  service_name     = module.serverless_app.service.name
  ssl_certificates = module.ssl.certificates
  backend_bucket   = module.assets.backend_bucket
}
