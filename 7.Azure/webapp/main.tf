terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "664b98cb-cc33-4ac5-a541-f8cf0203bb97"
  client_id       = "7aceb566-5abd-4f7e-8c08-48b1c30f7222"
  client_secret   = "9b2ed638-55b2-4f32-8dc0-c9195df712cf"
  tenant_id       = "68e088ff-b061-4e73-a795-36abe90c3df0"
  features {}
}

resource "random_pet" "prefix" {}

resource "azurerm_resource_group" "resource_group" {
  name     = "app-service-rg"
  location = "northeurope"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myappservice-plan"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "${random_pet.prefix.id}app"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }

}
