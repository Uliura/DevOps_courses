resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "eastus2"

  tags = {
    environment = "Demo"
  }
}


resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${random_pet.prefix.id}-law"
    location            = "eastus2"
    resource_group_name = azurerm_resource_group.default.name
    sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "eastus2"
    resource_group_name   = azurerm_resource_group.default.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}


resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_E2bs_v5"
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
      oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
      }
  }

  tags = {
    environment = "Demo"
  }
}
