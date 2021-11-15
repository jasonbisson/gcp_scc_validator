
module "cloud_function" {
  source                    = "./modules/cloud_function"
  project_id                = var.project_id
  org_id                    = var.org_id
  region                    = var.region
  terraform_service_account = var.terraform_service_account
  environment               = var.environment
  identity_running_function = var.identity_running_function
}
