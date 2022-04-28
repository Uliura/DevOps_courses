module "resource_group" {
  source = "../modules/resource_group" 
  name     = var.resource_group_name
  location = var.location
}

module "vnetwork" {
  source = "../modules/network/VNet"
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space

  depends_on = [
    module.resource_group
  ]  
}

module "subnetfe01" {
  source = "../modules/network/subnet"
  name                 = "${var.subnet_name}fe01"
  resource_group_name = var.resource_group_name
  network_name         = module.vnetwork.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    module.vnetwork
  ]  
}

module "subnetbe01" {
  source = "../modules/network/subnet"
  name                 = "${var.subnet_name}be01"
  resource_group_name = var.resource_group_name
  network_name         = module.vnetwork.name
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [
    module.subnetfe01
  ]  
}

module "public_ip" {
  source = "../modules/network/PublicIP"
  name                = var.ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  depends_on = [
    module.resource_group
  ]
}

module "NICfe01" {
  source = "../modules/network/network_interface"
  name                   = "${var.NIC_name}fe01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  subnet_id              = module.subnetfe01.id
  public_ip_address_id   = module.public_ip.id

  depends_on = [
    module.public_ip
  ]
}

module "NICbe01" {
  source = "../modules/network/network_interface"
  name                   = "${var.NIC_name}be01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  subnet_id              = module.subnetfe01.id
  public_ip_address_id   = null
  depends_on = [
    module.NICfe01
  ]
}

module "NICse01" {
  source = "../modules/network/network_interface"
  name                   = "${var.NIC_name}se01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  subnet_id              = module.subnetbe01.id
  public_ip_address_id   = null
  depends_on = [
    module.NICbe01
  ]
}

module "security_group_fe" {
  source = "../modules/network/network_security_group"
  name   = "${var.sg_name}fe"
  resource_group_name = var.resource_group_name
  location            = var.location

  depends_on = [
    module.NICse01
  ]  
}

module "security_group_be" {
  source = "../modules/network/network_security_group"
  name   = "${var.sg_name}be"
  resource_group_name = var.resource_group_name
  location            = var.location

  depends_on = [
    module.security_group_fe
  ]
}


resource "azurerm_network_security_rule" "ftp" {
    priority                    = 1010
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "21-22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    name                        = "ftp"
    resource_group_name         = var.resource_group_name
    network_security_group_name = module.security_group_fe.name

  depends_on = [
    module.security_group_be
  ]  
}

resource "azurerm_network_security_rule" "sftp" {
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "990"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  name                        = "sftp"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.security_group_fe.name

  depends_on = [
    azurerm_network_security_rule.ftp
  ]
}

resource "azurerm_network_security_rule" "ftpdata" {
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "21100-21110"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  name                        = "ftpdata"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.security_group_fe.name

  depends_on = [
    azurerm_network_security_rule.sftp
  ] 
}

resource "azurerm_network_security_rule" "denyall" {
  priority                    = 1040
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  name                        = "denyall"
  resource_group_name         = var.resource_group_name
  network_security_group_name = module.security_group_fe.name

  depends_on = [
    azurerm_network_security_rule.ftpdata
  ]
}


resource "azurerm_subnet_network_security_group_association" "fensg_association" {
  subnet_id                 = module.subnetfe01.id
  network_security_group_id = module.security_group_fe.id
 
  depends_on = [
    azurerm_network_security_rule.denyall
  ]
}

module "ftps_server" {
  source = "../modules/linux_instance"
  name   = "${var.vm_name}FE"
  resource_group_name = var.resource_group_name
  location            = var.location
  network_interface_id = [ 
    module.NICfe01.id,
    module.NICbe01.id
  ]

  custom_data = filebase64("script.sh")
  
  depends_on = [
   azurerm_network_security_rule.denyall
  ]
}

module "test_vm" {
  source = "../modules/linux_instance"
  name   = "${var.vm_name}BE"
  resource_group_name = var.resource_group_name
  location            = var.location
  network_interface_id = [module.NICse01.id]
  
  custom_data = var.custom_data

  depends_on = [
    module.ftps_server
  ]
}
