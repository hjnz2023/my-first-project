data "google_project" "project" {}

resource "google_sourcerepo_repository" "main" {
  # depends_on = [
  #   google_project_service.enabled_service["sourcerepo.googleapis.com"]
  # ]

  name = "${var.namespace}-hello"
}

locals {
  image = "gcr.io/${var.project_id}/${var.namespace}-hello:$COMMIT_SHA"
}

resource "google_cloudbuild_trigger" "main" {
  # depends_on = [
  #   google_project_service.enabled_service["cloudbuild.googleapis.com"]
  # ]

  trigger_template {
    branch_name = "main"
    repo_name   = google_sourcerepo_repository.main.name
  }

  build {
    step {
      name       = "node"
      entrypoint = "npm"
      args       = ["install"]
    }
    step {
      name       = "node"
      entrypoint = "npx"
      args       = ["nx", "run", "hello:test"]
    }
    step {
      name       = "node"
      entrypoint = "npx"
      args       = ["nx", "run-many", "-t=server"]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", local.image, "."]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", local.image]
    }
    step {
      name = "gcr.io/cloud-builders/gsutil"
      args = ["cp", "/workspace/dist/apps/hello/browser/*", "gs://${var.assets_bucket_name}/assets/"]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", var.deploy_service,
      "--image", local.image, "--region", var.region, "--platform", "managed", "--port", var.port]
    }
  }
}

resource "google_project_iam_member" "cloudbuild_roles" {
  depends_on = [
    google_cloudbuild_trigger.main
  ]
  project = var.project_id
  for_each = toset([
    "roles/run.admin",
    "roles/iam.serviceAccountUser"
  ])
  role   = each.key
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}