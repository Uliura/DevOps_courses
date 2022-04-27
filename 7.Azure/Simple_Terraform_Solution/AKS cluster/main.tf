resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "example" {
  solution_name         = var.log_analytics_solution_name
  workspace_resource_id = azurerm_log_analytics_workspace.example.id
  workspace_name        = azurerm_log_analytics_workspace.example.name
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = var.k8s_cluster_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = var.k8s_dns_prefix_name

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "standard_dc2ds_v3"
  }

  identity {
    type = "SystemAssigned"
  }
  addon_profile {
      oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      }
  }

}