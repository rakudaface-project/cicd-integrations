module "terraform_cloud" {
  depends_on = [google_iam_workload_identity_pool.cicd_integrations]

  source = "./modules/terraform_cloud_integration/"

  organization              = local.organization
  project                   = local.project
  repository                = "infrastructure-as-code"
  workload_identity_pool_id = google_iam_workload_identity_pool.cicd_integrations.workload_identity_pool_id
}

