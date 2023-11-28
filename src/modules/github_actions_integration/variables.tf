variable "organization" {
  type = string
}

variable "workload_identity_pool_id" {
  type = string
}

variable "application_repositories" {
  type = list(string)
}
