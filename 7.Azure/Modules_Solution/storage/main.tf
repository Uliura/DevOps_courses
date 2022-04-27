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

