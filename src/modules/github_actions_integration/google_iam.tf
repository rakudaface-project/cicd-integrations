data "google_client_config" "current" {}

data "google_iam_workload_identity_pool" "integrations" {
  workload_identity_pool_id = var.workload_identity_pool_id
}

resource "google_iam_workload_identity_pool_provider" "github_actions_id_provider" {
  workload_identity_pool_id          = data.google_iam_workload_identity_pool.integrations.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-oidc-provider"
  display_name                       = "GitHub Actions"
  description                        = "Identity Provider for GitHub Actions"

  attribute_condition = "attribute.repository_owner == \"${data.github_organization.current.name}\""
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.aud"              = "assertion.aud",
    "attribute.ref"              = "assertion.ref"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    issuer_uri = "https://${local.oidc_id_token.issuer}"
  }
}

resource "google_service_account" "artifact_registerer" {
  account_id   = "artifact-registerer"
  display_name = "Artifact Registerer"
}

resource "google_project_iam_member" "artifact_registerer" {
  project = data.google_client_config.current.project
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.artifact_registerer.member
}

resource "google_service_account_iam_binding" "artifact_registerer" {
  service_account_id = google_service_account.artifact_registerer.id
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${data.google_iam_workload_identity_pool.integrations.name}/attribute.ref/${local.oidc_id_token.assertion.ref}"
  ]
}

