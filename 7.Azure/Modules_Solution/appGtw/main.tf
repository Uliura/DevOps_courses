module "resource_group" {
  source = "../modules/resource_group" 
  name     = var.resource_group_name
  location = var.location
}

module "app_service_plan" {
  source = "../modules/app_service_plan"
  name                = var.app_service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  depends_on = [
    module.resource_group
  ]  
}

module "web_app" {
  source = "../modules/webapp"
  name                = var.app_service_name
  resource_group_name = var.resource_group_name
  location            = var.location
  app_service_plan_id = module.app_service_plan.id

  depends_on = [
    module.app_service_plan
  ]  
}

module "appgtvnetwork" {
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
  network_name         = module.appgtvnetwork.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [
    module.appgtvnetwork
  ]  
}

module "subnetbe01" {
  source = "../modules/network/subnet"
  name                 = "${var.subnet_name}be01"
  resource_group_name = var.resource_group_name
  network_name         = module.appgtvnetwork.name
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

module "app_gateway" {
  source = "../modules/network/AppGtw"
  name                 = var.app_gateway_service_name
  resource_group_name  = var.resource_group_name
  location             = var.location
  subnet_id            = module.subnetfe01.id
  public_ip_address_id = module.public_ip.id  
  fqdns                = [module.web_app.fqdns]

  depends_on = [
    module.web_app
  ] 
}
