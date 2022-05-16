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


locals {
  resource_group="app-grp"
  location="westus2"  
}


resource "azurerm_resource_group" "app_grp"{
  name=local.resource_group
  location=local.location
}

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.app_grp.name
  address_space       = ["10.0.0.0/16"]  
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

// This subnet is for the Azure Application Gateway resource
resource "azurerm_subnet" "SubnetB" {
  name                 = "SubnetB"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}


// This interface is for appvm1
resource "azurerm_network_interface" "app_interface1" {
  name                = "app-interface1"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"    
  }

  depends_on = [
    azurerm_virtual_network.app_network,
    azurerm_subnet.SubnetA
  ]
}

// This is the resource for appvm1
resource "azurerm_windows_virtual_machine" "app_vm1" {
  name                = "appvm1"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  size                = "Standard_D2_v5"
  admin_username      = "demousr"
  admin_password      = "Azure@123"  
  network_interface_ids = [
    azurerm_network_interface.app_interface1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.app_interface1
  ]
}

// This is the extension for appvm1
resource "azurerm_virtual_machine_extension" "vm_extension1" {
  name                 = "appvm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.app_vm1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
SETTINGS
}



// The public IP address is needed for the Azure Application Gateway

resource "azurerm_public_ip" "gateway_ip" {
  name                = "gateway-ip"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location
  allocation_method   = "Dynamic"
  
}


// Here we define the Azure Application Gateway resource
resource "azurerm_application_gateway" "app_gateway" {
  name                = "app-gateway"
  resource_group_name = azurerm_resource_group.app_grp.name
  location            = azurerm_resource_group.app_grp.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }


gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.SubnetB.id
  }

  frontend_port {
    name = "front-end-port"
    port = 443
  }

 frontend_ip_configuration {
    name                 = "front-end-ip-config"
    public_ip_address_id = azurerm_public_ip.gateway_ip.id    
  }
 
 ssl_certificate {
    name                 = "sert"
    data                 = "${filebase64("./ag.pfx")}"
    password             = "password"
 }

// Here we ensure the virtual machines are added to the backend pool
// of the Azure Application Gateway

  backend_address_pool{      
      name  = "videopool"
      ip_addresses = [
      "${azurerm_network_interface.app_interface1.private_ip_address}"
      ]
  
}
          
 

  backend_http_settings {
    name                  = "HTTPSetting"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }


 http_listener {
    name                           = "gateway-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "front-end-port"
    protocol                       = "Https"
    ssl_certificate_name           = "sert" 
  }

// This is used for implementing the URL routing rules
 request_routing_rule {
    name               = "RoutingRuleA"
    rule_type          = "PathBasedRouting"
    url_path_map_name  = "RoutingPath"
    http_listener_name = "gateway-listener"
  }

  url_path_map {
    name                               = "RoutingPath"    
    default_backend_address_pool_name   = "videopool"
    default_backend_http_settings_name  = "HTTPSetting"

     path_rule {
      name                          = "VideoRoutingRule"
      backend_address_pool_name     = "videopool"
      backend_http_settings_name    = "HTTPSetting"
      paths = [
        "/videos/*",
      ]
    }

  }
  }