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

resource "aws_iam_role" "terraform_planner" {
  name                 = "terraform-planner"
  assume_role_policy   = data.aws_iam_policy_document.assuming_planner_role.json
  managed_policy_arns  = [data.aws_iam_policy.read_only_access.arn]
  max_session_duration = 3600
}

data "aws_iam_policy" "read_only_access" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "assuming_planner_role" {
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
      values = [
        "organization:${local.oidc_id_token.subject.organization}:project:${local.oidc_id_token.subject.project}:workspace:${local.oidc_id_token.subject.workspace}:run_phase:plan"
      ]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.integration.arn]
    }
  }
}

resource "aws_iam_role" "terraform_applyer" {
  name                 = "terraform-applyer"
  assume_role_policy   = data.aws_iam_policy_document.assuming_applyer_role.json
  managed_policy_arns  = [data.aws_iam_policy.power_user_access.arn]
  max_session_duration = 3600
}

data "aws_iam_policy" "power_user_access" {
  arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

data "aws_iam_policy_document" "assuming_applyer_role" {
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
      values = [
        "organization:${local.oidc_id_token.subject.organization}:project:${local.oidc_id_token.subject.project}:workspace:${local.oidc_id_token.subject.workspace}:run_phase:apply"
      ]
    }
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.integration.arn]
    }
  }
}

