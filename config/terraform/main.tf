variable "project_id" {
  type = "string"
}


resource "google_cloudfunctions_function" "test" {
  name                      = "telegram-webhook"
  entry_point               = "main"
  available_memory_mb       = 128
  timeout                   = 61
  project                   = "${var.project_id}"
  region                    = "us-central1"
  trigger_http              = true
  source_archive_bucket     = "${google_storage_bucket.bucket.name}"
  source_archive_object     = "${google_storage_bucket_object.archive.name}"
  labels {
    deployment_name           = "test"
  }
}

resource "google_storage_bucket" "bucket" {
  name = "foine-b-bot-source"
  project = "foine-b-bot"
}

data "archive_file" "http_trigger" {
  type        = "zip"
  output_path = "${path.module}/http_trigger.zip"
  source_dir  = "${path.module}/files"
}

resource "google_storage_bucket_object" "archive" {
  name = "http_trigger.${data.archive_file.http_trigger.output_base64sha256}.zip"
  bucket = "${google_storage_bucket.bucket.name}"
  source = "${path.module}/http_trigger.zip"
  depends_on = ["data.archive_file.http_trigger"]
}
