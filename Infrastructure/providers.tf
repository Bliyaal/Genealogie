variable "kube_config_file" {
  type = string
}

variable "kube_config_context" {
  type = string
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kube_config_file
  config_context = var.kube_config_context
}