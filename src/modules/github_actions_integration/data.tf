data "github_organization" "current" {
  name = var.organization
}

data "github_repository" "applications" {
  for_each = toset(var.application_repositories)

  full_name = "${data.github_organization.current.name}/${each.value}"
}

