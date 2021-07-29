module "cloud_iam" {
  source                    = "./modules/cloud_iam"
  project_id                = var.project_id
  terraform_service_account = var.terraform_service_account
  customer_group            = var.customer_group
  user_email                = var.user_email
}

module "cloud_function" {
  source                    = "./modules/cloud_function"
  project_id                = var.project_id
  org_id                    = var.org_id
  region                    = var.region
  terraform_service_account = var.terraform_service_account
  environment               = var.environment
  identity_running_function = var.identity_running_function
}
