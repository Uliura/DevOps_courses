resource "azurerm_application_gateway" "app_gateway" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }


  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
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
    public_ip_address_id = var.public_ip_address_id    
  }
 
 ssl_certificate {
    name                 = "sert"
    data                 = "${filebase64("./ag.pfx")}"
    password             = "password"
 }

  
  backend_address_pool {
    name      = "app"
    fqdns     = var.fqdns
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
}