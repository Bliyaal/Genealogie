variable "kube_config_file" {
  type = string
}

variable "kube_config_context" {
  type = string
}

variable "postgres_volume_path" {
  type = string
}

locals {
  environments = toset([
    "dev",
    "prod",
  ])
}