provider "aws" {
  region = local.region.aws
}

provider "google" {
  project = local.organization
  region  = local.region.gcp
}

provider "github" {
  owner = local.organization
}

provider "tfe" {
  organization = local.organization
}

