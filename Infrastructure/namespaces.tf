resource "kubernetes_namespace_v1" "namespaces" {
  for_each = toset(["dev", "prod"])
  metadata {
    name = each.value
  }
}