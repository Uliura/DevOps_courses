terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.93.0"
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
  location = "westus2"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.0.0.0/16"]
  depends_on = [
    azurerm_resource_group.default
  ]  
}

resource "azurerm_subnet" "subnetfe01" {
  name                 = "subnetfe01"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

resource "azurerm_subnet" "subnetbe01" {
  name                 = "subnetbe01"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_subnet.subnetfe01
  ]

}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myTrfrmPublicIP"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Dynamic"
  depends_on = [
    azurerm_subnet.subnetbe01
  ]
}

# This interface is for appvm1
resource "azurerm_network_interface" "NICfe01" {
  name                = "NICfe01"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetfe01.id
    private_ip_address_allocation = "Dynamic" 
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id   
  }
  depends_on = [
    azurerm_public_ip.myterraformpublicip
  ]

}

resource "azurerm_network_interface" "NICbe01" {
  name                = "NICbe01"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetbe01.id
    private_ip_address_allocation = "Dynamic"    
  }
  depends_on = [
    azurerm_network_interface.NICfe01
  ]
}




// This interface is for appvm2
resource "azurerm_network_interface" "app_interface2" {
  name                = "app-interface2"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetbe01.id
    private_ip_address_allocation = "Dynamic"    
  }
  depends_on = [
    azurerm_network_interface.NICbe01
  ]
}


resource "azurerm_network_security_group" "fensg" {
  name                = "fensg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  depends_on = [
    azurerm_network_interface.app_interface2
  ]

}

resource "azurerm_network_security_group" "bensg" {
  name                = "bensg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  depends_on = [
    azurerm_network_security_group.fensg
  ]

}

resource "azurerm_network_security_rule" "open" {
  name                        = "ftpssh"
  priority                    = 1010
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "21-22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.fensg.name
  depends_on = [
    azurerm_network_security_group.bensg
  ]

}

resource "azurerm_network_security_rule" "open1" {
  name                        = "ftpsecure"
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "990"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.fensg.name
  depends_on = [
    azurerm_network_security_rule.open
  ]

}

resource "azurerm_network_security_rule" "open2" {
  name                        = "ftprange"
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "21100-21110"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.fensg.name
  depends_on = [
    azurerm_network_security_rule.open1
  ]

}


resource "azurerm_network_security_rule" "close" {
  name                        = "denyall"
  priority                    = 1040
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.default.name
  network_security_group_name = azurerm_network_security_group.fensg.name
  depends_on = [
    azurerm_network_security_rule.open2
  ]

}


resource "azurerm_subnet_network_security_group_association" "fensg_association" {
  subnet_id                 = azurerm_subnet.subnetfe01.id
  network_security_group_id = azurerm_network_security_group.fensg.id
  depends_on = [
    azurerm_network_security_rule.close
  ]

}

resource "azurerm_subnet_network_security_group_association" "bensg_association" {
  subnet_id                 = azurerm_subnet.subnetbe01.id
  network_security_group_id = azurerm_network_security_group.bensg.id
  depends_on = [
    azurerm_subnet_network_security_group_association.fensg_association
  ]

}



// This is the resource for appvm1
resource "azurerm_linux_virtual_machine" "app_vm1" {
  name                = "appvm1"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  size                = "Standard_D2s_v5"
  admin_username      = "azureuser"
  admin_password      = "Azureuser123"
  disable_password_authentication = false   
  network_interface_ids = [
    azurerm_network_interface.NICfe01.id,
    azurerm_network_interface.NICbe01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  custom_data = filebase64("script.sh")
  depends_on = [
    azurerm_subnet_network_security_group_association.bensg_association
  ]
}

// This is the resource for appvm2
resource "azurerm_linux_virtual_machine" "app_vm2" {
  name                = "appvm2"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  size                = "Standard_D2s_v5"
  admin_username      = "azureuser"
  admin_password      = "Azureuser123"
  disable_password_authentication = false  
  network_interface_ids = [
    azurerm_network_interface.app_interface2.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  depends_on = [
    azurerm_linux_virtual_machine.app_vm1
  ]
}

