module "resource_group" {
  source = "../modules/resource_group"  
}

module "vnetwork" {
  source = "../modules/network/VNet"
  depends_on = [
    module.resource_group
  ]  
}

module "subnetfe01" {
  source = "../modules/network/subnet"
  depends_on = [
    module.vnetwork
  ]  
}

module "subnetbe01" {
  source = "../modules/network/subnet"
  depends_on = [
    module.subnetfe01
  ]  
}

module "public_ip" {
  source = "../modules/network/PublicIP"
  
}

module "NICfe01" {
  source = "../modules/network/network_interface"
  depends_on = [
    module.public_ip
  ]
}

module "NICbe01" {
  source = "../modules/network/network_interface"
  depends_on = [
    module.NICfe01
  ]
}

module "NICse01" {
  source = "../modules/network/network_interface"
  depends_on = [
    module.NICbe01
  ]
}

module "security_group_fe" {
  source = "../modules/network/network_security_group"
  depends_on = [
    module.NICse01
  ]  
}

module "security_group_be" {
  source = "../modules/network/network_security_group"
  depends_on = [
    module.security_group_fe
  ]
}

module "security_rule_open1" {
  source = "../modules/network/network_security_rule"
  depends_on = [
    module.security_group_be
  ]  
}

module "security_rule_open2" {
  source = "../modules/network/network_security_rule"
  depends_on = [
    module.security_rule_open1
  ]
}

module "security_rule_open3" {
  source = "../modules/network/network_security_rule"
  depends_on = [
    module.security_rule_open2
  ] 
}

module "security_rule_close" {
  source = "../modules/network/network_security_rule"
  depends_on = [
    module.security_rule_open3
  ]
}


resource "azurerm_subnet_network_security_group_association" "fensg_association" {
  subnet_id                 = azurerm_subnet.subnetfe01.id
  network_security_group_id = azurerm_network_security_group.fensg.id
  depends_on = [
    module.security_rule_close
  ]
}

resource "azurerm_subnet_network_security_group_association" "bensg_association" {
  subnet_id                 = azurerm_subnet.subnetbe01.id
  network_security_group_id = azurerm_network_security_group.bensg.id
  depends_on = [
    azurerm_subnet_network_security_group_association.fensg_association
  ]

}

module "ftps_server" {
  source = "../modules/linux_instance"

  custom_data = filebase64("script.sh")
  depends_on = [
    azurerm_subnet_network_security_group_association.bensg_association
  ]
}

module "test_vm" {
  source = "../modules/linux_instance"
  
}
