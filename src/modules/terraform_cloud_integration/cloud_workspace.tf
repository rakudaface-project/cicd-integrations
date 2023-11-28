data "tfe_organization" "current" {
  name = var.organization
}

data "tfe_project" "current" {
  name         = var.project
  organization = data.tfe_organization.current.name
}

resource "tfe_workspace" "target" {
  name         = "${data.github_repository.target.name}-for-${data.tfe_project.current.name}"
  organization = data.tfe_organization.current.name
  project_id   = data.tfe_project.current.id

  source_name = data.github_repository.this.full_name
  source_url  = data.github_repository.this.html_url

  execution_mode = "remote"

  dynamic "vcs_repo" {
    for_each = var.vcs_enabled ? ["enabled"] : []
    content {
      branch                     = data.github_repository.target.default_branch
      identifier                 = data.github_repository.target.full_name
      ingress_submodules         = true
      github_app_installation_id = data.tfe_github_app_installation.app.id
    }
  }
  working_directory = "/src"
  trigger_patterns  = ["/src/*.tf", "/src/**/*.tf", "/src/*.hcl", "/src/**/*.hcl"]
}

data "tfe_github_app_installation" "app" {
  installation_id = 42368836
}

data "github_organization" "current" {
  name = var.organization
}

data "github_repository" "target" {
  full_name = "${data.github_organization.current.name}/${var.repository}"
}

data "github_repository" "this" {
  full_name = "${data.github_organization.current.name}/cicd-integrations"
}

resource "tfe_variable" "environment_variable" {
  for_each = local.environmental_variables

  key   = each.key
  value = each.value

  workspace_id = tfe_workspace.target.id

  category = "env"
}

resource "tfe_workspace_variable_set" "oidc_enabled" {
  workspace_id    = tfe_workspace.target.id
  variable_set_id = data.tfe_variable_set.oidc_enabled.id
}

data "tfe_variable_set" "oidc_enabled" {
  organization = data.tfe_organization.current.name
  name         = "OpenID Connect Enabled"
}

