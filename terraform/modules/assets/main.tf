resource "google_storage_bucket" "main" {
  name                        = var.name
  location                    = var.region
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "main" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "main" {
  name        = var.name
  bucket_name = google_storage_bucket.main.name
}