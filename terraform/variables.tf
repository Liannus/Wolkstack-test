variable "oidc_thumbprint_list" {
  type = list(string)
}

variable "external_dns_role_tags" {
  type = object({})
}

variable "region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "env" {
  description = "Depolyment environment"
  default     = "dev"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "master"
}

variable "repository_owner" {
  description = "GitHub repository owner"
  default     = "Liannus"
}

variable "repository_name" {
  description = "GitHub repository name"
  default     = "Wolkstack-test"
}

variable "docker_hub_username" {
  description = "docker-hub username"
  default     = "liannus"
  type        = string
}

variable "docker_hub_password" {
  description = "docker-hub password FILL THROUGH ENV VARIABLES FOR SECURITY"
  type        = string
}

variable "github_token" {
  description = "github token FILL THROUGH ENV VARIABLES FOR SECURITY"
  type        = string
}