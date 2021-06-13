# Secure Command Center Validator

## Purpose

The purpose of this repository is to demonstrate how our secure validator script can first detect an insecure infrastructure deployment in a development environment and then block the deployment in a production environment. 

## Prerequisites

To run the commands described in this document, you need to have the following
installed:

- The [Google Cloud SDK](https://cloud.google.com/sdk/install) version 319.0.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.6.
- An existing project and GCS Bucket to store Terraform state

**Note:** Make sure that you use the same version of Terraform throughout this
series. Otherwise, you might experience Terraform state snapshot lock errors.


## Deploying Terraform locally 

1. Copy the backend:
   ```
   cp backend.tf.example backend.tf
   ```
1. Update `backend.tf` with an existing GCS bucket to store Terraform state.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:
    ```
    mv terraform.example.tfvars terraform.tfvars
    ```
1. Run `terraform init`.
1. Run `terraform plan` and review the output.
1. Run `terraform apply`.
1. Run `terraform output terraform_service_account` to get the email address of the admin. You need this address in a later procedure.
1. Run `terraform output gcs_bucket_tfstate` to get your Google Cloud bucket name from Terraform's state.


## Deploying with Cloud Build

1. Clone the repo.
   ```
   gcloud source repos clone gcp-scc --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```
1. Navigate into the repo and change to a non-production branch.
   ```
   cd gcp-scc
   git checkout -b plan
   ```
1. Copy contents of foundation to new repo (terraform variables will updated in a future step).
   ```
   cp -RT ../gcp-scc-validator .
   ```
1. Ensure wrapper script can be executed.
   ```
   chmod 755 ./tf-wrapper.sh
   ```
1. Run the following command:
   ```
   for i in `find -name 'backend.tf'`; do sed -i 's/UPDATE_ME/GCS_BUCKET_NAME/' $i; done
   ```
   where `GCS_BUCKET_NAME` is the name of your bucket from the steps you ran
   earlier.
1. Rename `terraform.example.tfvars` to `terraform.tfvars` and update the file with values from your environment:
    ```
    mv terraform.example.tfvars terraform.tfvars
    ```

1. Commit changes.
   ```
   git add .
   git commit -m 'Your message'
   ```
1. Push your plan branch to trigger a plan. For this command, the branch `plan` is not a special one. Any branch which name is different from `development`, `non-production` or `production` will trigger a Terraform plan.
   ```
   git push --set-upstream origin plan
   ```
1. Review the plan output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to production branch.
   ```
   git checkout -b development
   git push origin development
   ```
1. Review the apply output in your Cloud Build project. https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_id | The project id where the GCS bucket will be deployed. | `string` | n/a | yes |
| bucket\_name\_prefix | Prefex of GCS bucket that will be deployed. | `string` | n/a | yes |
| customer\_group | Name of Google Group that will permission to manage the GCS bucket. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| storage\_bucket\_labels | Labels for Storage bucket | `map(string)` | n/a | no |

## Outputs

| Name | Description |
|------|-------------|
| gcs_bucket | The GCS bucket name that has been deployed. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

