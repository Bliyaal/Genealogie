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

          volume_mount {
            name       = kubernetes_persistent_volume_claim_v1.postgres[each.key].metadata[0].name
            mount_path = "/var/lib/postgresql/data"
          }
        }

        volume {
          name = kubernetes_persistent_volume_claim_v1.postgres[each.key].metadata[0].name

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.postgres[each.key].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  for_each = local.environments

  metadata {
    name = "pgdata"
    namespace = kubernetes_namespace_v1.namespaces[each.key].metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = kubernetes_persistent_volume_v1.postgres[each.key].spec[0].storage_class_name

    resources {
      requests = {
        storage = kubernetes_persistent_volume_v1.postgres[each.key].spec[0].capacity.storage
      }
    }

    volume_name = kubernetes_persistent_volume_v1.postgres[each.key].metadata[0].name
  }
}

resource "kubernetes_persistent_volume_v1" "postgres" {
  for_each = local.environments

  metadata {
    name = "pgdata-${each.key}"
  }

  spec {
    capacity = {
      storage = "2Gi"
    }

    access_modes = ["ReadWriteOnce"]
    storage_class_name = "local-storage"

    persistent_volume_source {
      host_path {
        path = "${var.postgres_volume_path}/${each.key}"
      }
    }
  }
}

resource "kubernetes_secret_v1" "example" {
  for_each = local.environments
  metadata {
    name      = "db-login"
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