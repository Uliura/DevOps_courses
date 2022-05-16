terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }
}

provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {}
}

resource "random_pet" "prefix" {}

resource "azurerm_resource_group" "default" {
  name     = "${random_pet.prefix.id}-rg"
  location = "eastus2"

  tags = {
    environment = "Demo"
  }
}


resource "azurerm_storage_account" "storage_account" {
  name                     = "terraformgekastore"
  resource_group_name      = azurerm_resource_group.default.name
  location                 = "westus2"  
  account_tier             = "Standard"
  account_replication_type = "RAGZRS"
  access_tier              = "Cool"
  allow_blob_public_access = true
}

resource "azurerm_storage_container" "example" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

