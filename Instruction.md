# Initilize YOUR OWN workspace in Terraform cloud

Add `src/override.tf` that includes proper settings below.

- set `local.organization` as your organization name you belong to
- set `local.project` as your project name
- set `local.region` for each cloud provider
- set `cloud` configuration in `terraform` block

example,

```override.tf
terraform {
  cloud {
    organization = "<YOUR ORGANIZATION NAME>"
    workspaces {
      project = "<YOUR PROJECT NAME>"
      name    = "cicd-integrations-for-<YOUR PROJECT NAME>"
    }
  }
}

locals {
  organization = "<YOUR ORGANIZATION NAME"
  project      = "<YOUR PROJECT NAME>"
  region = {
    aws = "<PREFERRED AWS REGION>"
    gcp = "<PREFERRED GCP REGION>"
  }
}
```

