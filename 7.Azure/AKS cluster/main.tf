terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.93.0"
    }
  }
}
resource "random_pet" "prefix" {}

provider "azurerm" {
  subscription_id = "664b98cb-cc33-4ac5-a541-f8cf0203bb97"
  client_id       = "7aceb566-5abd-4f7e-8c08-48b1c30f7222"
  client_secret   = "9b2ed638-55b2-4f32-8dc0-c9195df712cf"
  tenant_id       = "68e088ff-b061-4e73-a795-36abe90c3df0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${random_pet.prefix.id}-k8s-resources"
  location = "eastus2"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "${random_pet.prefix.id}-law"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "example" {
  solution_name         = "Containers"
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
  name                = "${random_pet.prefix.id}-k8s"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

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