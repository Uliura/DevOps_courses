resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_app_service_plan" "app_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku {
    tier = "Basic"
    size = "B1"
  }
  depends_on = [
    azurerm_resource_group.rg
  ]  
}

resource "azurerm_app_service" "webapp" {
  name                = var.app_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  source_control {
    repo_url           = "https://github.com/Azure-Samples/nodejs-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
  
  depends_on = [
    azurerm_app_service_plan.app_plan
  ]
}

resource "azurerm_virtual_network" "app_network" {
  name                = var.vnet_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]  
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}

resource "azurerm_subnet" "SubnetB" {
  name                 = "SubnetB"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [
    azurerm_virtual_network.app_network
  ]
}


resource "azurerm_public_ip" "gateway_ip" {
  name                = var.public_ip_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.domain_name
}


resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
    name = "https-front-end-port"
    port = 443
  }

  frontend_port {
    name = "http-front-end-port"
    port = 80
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
    fqdns     = [azurerm_app_service.webapp.default_site_hostname]
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
    name                           = "http-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "http-front-end-port"
    protocol                       = "Http"
  }

 http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "front-end-ip-config"
    frontend_port_name             = "https-front-end-port"
    protocol                       = "Https"
    ssl_certificate_name           = "sert" 
  }

  redirect_configuration {
    name                 = "redirect"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"

  }

 request_routing_rule {
    name               = "httpsRule"
    rule_type          = "Basic"
    backend_address_pool_name = "app"
    http_listener_name = "https-listener"
    backend_http_settings_name = "app"
  }

 request_routing_rule {
    name               = "httpRule"
    rule_type          = "Basic"
    redirect_configuration_name = "redirect"
    http_listener_name = "http-listener"
  }

  depends_on = [
    azurerm_app_service.webapp
  ]
}