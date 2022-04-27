output "name" {
  value       = azurerm_kubernetes_cluster.k8s.name
  description = "Specifies the name of the AKS cluster."
}

output "id" {
  value       = azurerm_kubernetes_cluster.k8s.id
  description = "Specifies the resource id of the AKS cluster."
}
