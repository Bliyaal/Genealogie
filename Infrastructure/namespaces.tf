resource "kubernetes_namespace_v1" "namespaces" {
  for_each = local.environments
  metadata {
    name = each.key
  }
}