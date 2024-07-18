resource "kubernetes_deployment_v1" "postgres" {
  for_each = local.environments

  metadata {
    name      = "postgres"
    namespace = each.key
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name              = "postgres"
          image             = "docker.io/postgres:16.3-alpine"
          image_pull_policy = "IfNotPresent"
          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }
          port {
            container_port = 5432
          }
          env {
            name  = "POSTGRES_DB"
            value = "genealogie"
          }
          env {
            name  = "POSTGRES_USER"
            value = random_pet.db_user[each.key].id
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = random_password.db_password[each.key].result
          }
        }
      }
    }
  }
}

resource "kubernetes_secret_v1" "example" {
  for_each = local.environments
  metadata {
    name      = "db_login"
    namespace = kubernetes_namespace_v1.namespaces[each.key].metadata[0].name
  }

  data = {
    username = random_pet.db_user[each.key].id
    password = random_password.db_password[each.key].result
  }

  type = "kubernetes.io/basic-auth"
}

resource "random_pet" "db_user" {
  for_each  = local.environments
  length    = 2
  separator = "-"
}

resource "random_password" "db_password" {
  for_each = local.environments
  length   = random_integer.password_length[each.key].result
}

resource "random_integer" "password_length" {
  for_each = local.environments
  min      = 12
  max      = 18
}