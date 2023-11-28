resource "google_project_service" "api_for_workload_identity" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ])
  service = each.value
}

resource "google_iam_workload_identity_pool" "cicd_integrations" {
  workload_identity_pool_id = "cicd-integrations-id-pool"
  display_name              = "ID Pool for CI/CD Integrations"
  description               = "ID Pool for CI/CD integrations such as Terraform Cloud, GitHub Actions, etc."
}

