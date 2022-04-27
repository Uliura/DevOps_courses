resource "azurerm_network_security_rule" "nsrule" {
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "21-22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  name                        = var.name
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}
