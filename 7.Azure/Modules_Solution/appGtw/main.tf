module "resource_group" {
  source = "../modules/resource_group"  
}

module "app_service_plan" {
  source = "../modules/app_service_plan"
  depends_on = [
    module.resource_group
  ]  
}

module "web_app" {
  source = "../modules/webapp"
  depends_on = [
    module.app_service_plan
  ]  
}

module "vnetwork" {
  source = "../modules/network/VNet"
  depends_on = [
    module.resource_group
  ]
}

module "subnet01" {
  source = "../modules/network/subnet"
  depends_on = [
    module.vnetwork
  ]
}

module "subnet02" {
  source = "../modules/network/subnet"
  depends_on = [
    module.vnetwork
  ]
}

module "public_ip" {
  source = "../modules/network/PublicIP"
  
}

module "app_gateway" {
  source = "../modules/network/AppGtw"
  depends_on = [
    module.web_app
  ] 
}
