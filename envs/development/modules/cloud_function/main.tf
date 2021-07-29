# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "random_id" "random_suffix" {
  byte_length = 4
}

resource "google_project_service" "project_services" {
  project                    = var.project_id
  count                      = var.enable_apis ? length(var.activate_apis) : 0
  service                    = element(var.activate_apis, count.index)
  disable_on_destroy         = var.disable_services_on_destroy
  disable_dependent_services = var.disable_dependent_services
}

resource "google_service_account" "main" {
  project      = var.project_id
  account_id   = "scc-${random_id.random_suffix.hex}"
  display_name = "${var.environment}${random_id.random_suffix.hex}"
}


resource "google_organization_iam_member" "binding" {
  org_id     = var.org_id
  role       = "roles/securitycenter.adminViewer"
  member     = "serviceAccount:${google_service_account.main.email}"
  depends_on = [google_cloudfunctions_function.function]
}

resource "google_project_iam_member" "binding" {
  project    = var.project_id
  role       = "roles/logging.logWriter"
  member     = "serviceAccount:${google_service_account.main.email}"
  depends_on = [google_cloudfunctions_function.function]
}


resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "user:${var.identity_running_function}"
}

resource "google_cloudfunctions_function" "function" {
  project          = var.project_id
  region           = var.region
  name             = var.environment
  entry_point      = var.environment
  ingress_settings = "ALLOW_ALL"
  #ingress_settings = "ALLOW_INTERNAL_AND_GCLB"
  trigger_http          = true
  runtime               = var.runtime
  service_account_email = google_service_account.main.email
  source_archive_bucket = google_storage_bucket.gcf_source_bucket.name
  source_archive_object = google_storage_bucket_object.gcf_zip_gcs_object.name
  labels = {
    my-label = var.environment
  }
  environment_variables = {
    compliance   = "pci",
    critical_max = 0,
    high_max     = 40,
    medium_max   = 50
  }
}

resource "google_storage_bucket" "gcf_source_bucket" {
  name                        = "${var.environment}${random_id.random_suffix.hex}"
  uniform_bucket_level_access = true
  location                    = var.region
  project                     = var.project_id
}

resource "google_storage_bucket_object" "gcf_zip_gcs_object" {
  name   = var.environment
  bucket = google_storage_bucket.gcf_source_bucket.name
  source = data.archive_file.gcf_zip_file.output_path
}

data "archive_file" "gcf_zip_file" {
  type        = "zip"
  output_path = "${path.module}/function_source/${var.environment}.zip"

  source {
    content  = file("${path.module}/function_source/main.py")
    filename = "main.py"
  }

  source {
    content  = file("${path.module}/function_source/requirements.txt")
    filename = "requirements.txt"
  }

}
