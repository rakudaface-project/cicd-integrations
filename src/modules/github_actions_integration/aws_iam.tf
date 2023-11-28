resource "aws_iam_openid_connect_provider" "integration" {
  url             = "https://${local.oidc_id_token.issuer}"
  client_id_list  = [local.oidc_id_token.audience]
  thumbprint_list = [for i, cert in data.tls_certificate.jwks_uri.certificates : cert.sha1_fingerprint]
}

data "tls_certificate" "jwks_uri" {
  url = jsondecode(data.http.openid_configuration.response_body).jwks_uri
}

data "http" "openid_configuration" {
  url = "https://${local.oidc_id_token.issuer}/.well-known/openid-configuration"
}

resource "aws_iam_role" "container_registerer" {
  name                 = "container_registerer"
  assume_role_policy   = data.aws_iam_policy_document.assuming_container_registry_power_user_role.json
  managed_policy_arns  = [data.aws_iam_policy.container_registry_power_user.arn]
  max_session_duration = 3600
}

data "aws_iam_policy" "container_registry_power_user" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

data "aws_iam_policy_document" "assuming_container_registry_power_user_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringLike"
      variable = "${local.oidc_id_token.issuer}:aud"
      values   = [local.oidc_id_token.audience]
    }
    condition {
      test     = "StringLike"
      variable = "${local.oidc_id_token.issuer}:sub"
      values   = [for i, repository in data.github_repository.applications : "repo:${repository.full_name}:ref:${local.oidc_id_token.assertion.ref}"]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.integration.arn]
    }
  }
}

