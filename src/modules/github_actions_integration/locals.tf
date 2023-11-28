locals {
  oidc_id_token = {
    issuer   = "token.actions.githubusercontent.com"
    audience = "sts.amazonaws.com"
    assertion = {
      ref = "refs/heads/main"
    }
  }
}
