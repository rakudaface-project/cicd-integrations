data "google_iam_workload_identity_pool" "integrations" {
  workload_identity_pool_id = var.workload_identity_pool_id
}

resource "google_iam_workload_identity_pool_provider" "terraform_cloud_id_provider" {
  workload_identity_pool_id          = data.google_iam_workload_identity_pool.integrations.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-cloud-oidc-provider"
  display_name                       = "Terraform Cloud"
  description                        = "Identity Provider for Terraform Cloud"

  attribute_condition = "attribute.organization_name == \"${local.oidc_id_token.subject.organization}\""
  attribute_mapping = {
    "google.subject"              = "assertion.sub",
    "attribute.aud"               = "assertion.aud",
    "attribute.run_phase"         = "assertion.terraform_run_phase",
    "attribute.project_id"        = "assertion.terraform_project_id",
    "attribute.project_name"      = "assertion.terraform_project_name",
    "attribute.workspace_id"      = "assertion.terraform_workspace_id",
    "attribute.workspace_name"    = "assertion.terraform_workspace_name",
    "attribute.organization_id"   = "assertion.terraform_organization_id",
    "attribute.organization_name" = "assertion.terraform_organization_name",
    "attribute.run_id"            = "assertion.terraform_run_id",
    "attribute.full_workspace"    = "assertion.terraform_full_workspace",
  }

  oidc {
    issuer_uri = "https://${local.oidc_id_token.issuer}"
  }
}

resource "google_service_account" "terraform_planner" {
  account_id   = "terraform-planner"
  display_name = "Terraform Planner"
}

resource "google_project_iam_member" "terraform_planner" {
  project = data.google_client_config.current.project
  role    = "roles/viewer"
  member  = google_service_account.terraform_planner.member
}

resource "google_service_account_iam_binding" "terraform_planner" {
  service_account_id = google_service_account.terraform_planner.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.integrations.name}/attribute.run_phase/plan"
  ]
}

resource "google_service_account" "terraform_applyer" {
  account_id   = "terraform-applyer"
  display_name = "Terraform Applyer"
}

resource "google_project_iam_member" "terraform_applyer" {
  project = data.google_client_config.current.project
  role    = "roles/editor"
  member  = google_service_account.terraform_applyer.member
}

resource "google_service_account_iam_binding" "terraform_applyer" {
  service_account_id = google_service_account.terraform_applyer.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.integrations.name}/attribute.run_phase/apply"
  ]
}

