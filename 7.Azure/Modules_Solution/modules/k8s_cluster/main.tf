resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.k8s_dns_prefix_name

  default_node_pool {
    name       = var.default_node_pool_name
    node_count = var.default_node_pool_node_count
    vm_size    = var.default_node_pool_vm_size
  }

  identity {
    type = var.identity
  }
  addon_profile {
      oms_agent {
      enabled                    = var.oms_agent.enabled
      log_analytics_workspace_id = var.log_analytics_workspace_id
      }
  }

}