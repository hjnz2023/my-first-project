locals {
  vpc_access_annotation = var.vpc_access == null ? {} : {
    "run.googleapis.com/vpc-access-connector" = var.vpc_access.connector.id
    "run.googleapis.com/vpc-access-egress"    = var.vpc_access.egress
  }
}
resource "google_cloud_run_service" "main" {
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      metadata.0.annotations["client.knative.dev/user-image"],
      metadata.0.annotations["run.googleapis.com/client-name"],
      metadata.0.annotations["run.googleapis.com/client-version"],
      template.0.metadata.0.annotations["client.knative.dev/user-image"],
      template.0.metadata.0.annotations["run.googleapis.com/client-name"],
      template.0.metadata.0.annotations["run.googleapis.com/client-version"],
      template.0.spec.0.containers.0.image
    ]
  }

  # depends_on = [
  #   google_project_service.enabled_service["run.googleapis.com"]
  # ]
  name     = var.service_name
  location = var.region
  project  = var.project_id

  template {
    metadata {
      annotations = merge(local.vpc_access_annotation)
    }
  }

  autogenerate_revision_name = true

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  service     = google_cloud_run_service.main.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
