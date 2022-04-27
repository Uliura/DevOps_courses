resource "azurerm_network_security_group" "sgname" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

}