data "google_project" "project" {}

resource "google_sourcerepo_repository" "main" {
  # depends_on = [
  #   google_project_service.enabled_service["sourcerepo.googleapis.com"]
  # ]

  name = "${var.namespace}-hello"
}

resource "google_storage_bucket_object" "newrelic_agent_js" {
  name   = "assets/newrelic_agent.js"
  source = "${path.module}/files/newrelic_agent.js"
  bucket = var.assets_bucket_name
}

locals {
  image       = "gcr.io/${var.project_id}/${var.namespace}-hello:$COMMIT_SHA"
  build_image = "gcr.io/${var.project_id}/${var.namespace}-hello-build:$BRANCH_NAME"
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

    dynamic "step" {
      for_each = contains(var.optional_build_steps, "build_image") == true ? [] : [1]
      content {
        name = "gcr.io/kaniko-project/executor:latest"
        args = ["--dockerfile=Dockerfile.build", "--destination=${local.build_image}", "--cache=true", "--cache-ttl=6h"]
      }
    }
    step {
      name       = local.build_image
      entrypoint = "pnpm"
      args       = ["i", "--frozen-lockfile", "--store-dir", "/share/.pnpm-store"]
      id         = "install"
    }
    step {
      name       = local.build_image
      entrypoint = "pnpm"
      args       = ["nx", "run", "hello:test"]
      wait_for   = ["install"]
    }
    step {
      name       = local.build_image
      entrypoint = "pnpm"
      args       = ["nx", "server", "hello"]
      id         = "build"
      wait_for   = ["install"]
    }
    step {
      name     = "gcr.io/kaniko-project/executor:latest"
      args     = ["--destination=${local.image}", "--cache=true", "--cache-ttl=6h"]
      wait_for = ["build"]
      id       = "package'"
    }
    step {
      name     = "gcr.io/cloud-builders/gsutil"
      args     = ["-m", "cp", "/workspace/dist/apps/hello/browser/*", "gs://${var.assets_bucket_name}/assets/"]
      wait_for = ["build"]
    }
    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = ["run", "deploy", var.deploy_service,
      "--image", local.image, "--region", var.region, "--platform", "managed", "--port", var.port]
    }
    # step {
    #   name = "curl"
    #   args = ["-X", "POST", "-H", "Content-Type: application/json", "-d", "{\"text\": \"Build ${COMMIT_SHA} of ${REPO_NAME} has been deployed to ${var.deploy_service}\"}", var.slack_webhook]
    # }
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
