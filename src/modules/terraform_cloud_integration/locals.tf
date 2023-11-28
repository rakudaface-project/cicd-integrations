locals {
  oidc_id_token = {
    issuer   = "app.terraform.io"
    audience = "aws.workload.identity"
    subject = {
      organization = data.tfe_organization.current.name
      project      = data.tfe_project.current.name
      workspace    = tfe_workspace.target.name
    }
  }
  environmental_variables = {
    AWS_REGION                          = data.aws_region.current.name
    GOOGLE_REGION                       = data.google_client_config.current.region
    GOOGLE_PROJECT                      = data.google_client_config.current.project
    TFC_AWS_APPLY_ROLE_ARN              = aws_iam_role.terraform_applyer.arn
    TFC_AWS_PLAN_ROLE_ARN               = aws_iam_role.terraform_planner.arn
    TFC_GCP_APPLY_SERVICE_ACCOUNT_EMAIL = google_service_account.terraform_applyer.email
    TFC_GCP_PLAN_SERVICE_ACCOUNT_EMAIL  = google_service_account.terraform_planner.email
    TFC_GCP_WORKLOAD_PROVIDER_NAME      = google_iam_workload_identity_pool_provider.terraform_cloud_id_provider.name
  }
}

