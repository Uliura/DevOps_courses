resource "azurerm_subnet" "SubnetA" {
  name                 = var.name
  location             = var.location
  virtual_network_name = var.network_name
  address_prefixes     = var.address_prefixes
}
