resource "azurerm_storage_container" "example" {
  name                  = var.name
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
}
