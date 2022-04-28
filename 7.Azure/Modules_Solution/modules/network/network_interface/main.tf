resource "azurerm_network_interface" "NIC" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "Internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic" 
    public_ip_address_id          = var.public_ip_address_id
  }
}