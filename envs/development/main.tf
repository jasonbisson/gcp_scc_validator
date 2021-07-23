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


resource "random_id" "suffix" {
  byte_length = 2
}

/***********************************************
  GCS Bucket 
 ***********************************************/

resource "google_storage_bucket" "batch_data" {
  project                     = var.project_id
  name                        = "${var.project_id}-${var.bucket_name_prefix}-${random_id.suffix.hex}"
  location                    = var.default_region
  labels                      = var.storage_bucket_labels
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/***********************************************
Access
 ***********************************************/

resource "google_storage_bucket_iam_binding" "customers" {
  bucket = google_storage_bucket.batch_data.name
  role   = "roles/storage.admin"
  members = [
    "group:${var.customer_group}"
  ]
}

/******************************************
  Module project_iam_binding calling
 *****************************************/
module "project_iam_binding" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = [var.project_id]
  mode     = "additive"

  bindings = {
    "roles/editor" = [
      "user:${var.user_email}"
    ]
  }
}

