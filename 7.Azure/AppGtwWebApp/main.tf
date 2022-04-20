terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "664b98cb-cc33-4ac5-a541-f8cf0203bb97"
  client_id       = "7aceb566-5abd-4f7e-8c08-48b1c30f7222"
  client_secret   = "9b2ed638-55b2-4f32-8dc0-c9195df712cf"
  tenant_id       = "68e088ff-b061-4e73-a795-36abe90c3df0"
  features {}
}


locals {
  resource_group="app-grp"
  location="centralus"  
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

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myappservice-plan"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name

  sku {
    tier = "Basic"
    size = "B1"
  }
  depends_on = [
    azurerm_resource_group.app_grp
  ]
}

resource "azurerm_app_service" "app_service" {
  name                = "gekawebapp0301"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id

  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
  depends_on = [
    azurerm_app_service_plan.app_service_plan
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

  
  backend_address_pool {
    name      = "app"
    fqdns     = ["gekawebapp0301.azurewebsites.net"]
  }  

  probe {
    name                                      = "httpsprobe"
    protocol                                  = "Https"
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 120
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
  }


  backend_http_settings {
    name                  = "app"
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = "443"
    protocol              = "Https"
    request_timeout       = 30
    pick_host_name_from_backend_address = "true"
    probe_name            = "httpsprobe"

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
    name               = "appRoutingRule"
    rule_type          = "Basic"
    backend_address_pool_name = "app"
    http_listener_name = "gateway-listener"
    backend_http_settings_name = "app"
  }

  depends_on = [
    azurerm_app_service.app_service
  ]
}