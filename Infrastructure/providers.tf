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
  config_path    = "/home/michel/.kube/config"
  config_context = "k3d-webserver"
}