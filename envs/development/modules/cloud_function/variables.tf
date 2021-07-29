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

variable "project_id" {
  description = "Project ID to hold GCF"
}

variable "environment" {
  description = "Unique environment name to link the whole deployment"
}

variable "region" {
  description = "Region where cloud function is deployed"
  type        = string
  default     = "us-central1"
}

variable "org_id" {
  description = "Organization ID to monitor"
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "identity_running_function" {
  description = "Identity that will invoke the cloud function"
  type        = string
}

variable "enable_apis" {
  description = "Whether to actually enable the APIs. If false, this module is a no-op."
  default     = "true"
}

variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy"
  default     = "false"
  type        = string
}

variable "disable_dependent_services" {
  description = "Whether services that are enabled and which depend on this service should also be disabled when this service is destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_dependent_services"
  default     = "false"
  type        = string
}

variable "activate_apis" {
  description = "The list of apis to activate within the project"
  default     = ["cloudbuild.googleapis.com", "storage.googleapis.com", "artifactregistry.googleapis.com", "containerregistry.googleapis.com", "cloudfunctions.googleapis.com", "securitycenter.googleapis.com"]
  type        = list(string)
}


variable "runtime" {
  description = "Runtime environment for cloud function"
  type        = string
  default     = "python37"
}

