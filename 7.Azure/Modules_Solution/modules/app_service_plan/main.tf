resource "azurerm_app_service_plan" "app_plan" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    tier = "Basic"
    size = "B1"
  }
}
