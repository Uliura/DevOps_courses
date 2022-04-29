module "resource_group" {
  source = "../modules/resource_group"
  name     = var.resource_group_name
  location = var.location  
}

module "storage_account" {
  source = "../modules/storage"
  name                             = var.storage_account_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  depends_on = [
    module.resource_group
  ]
}

module "container" {
  source = "../modules/storage_container"
  name                  = var.storage_container_name
  storage_account_name  = module.storage_account.name
  depends_on = [
    module.storage_account
  ] 
}

module "public_ip" {
  source = "../modules/network/PublicIP"
  name                = var.ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  depends_on = [
    module.container
  ]
}

module "vnetwork" {
  source = "../modules/network/VNet"
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space

  depends_on = [
    module.public_ip
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

module "NICfe01" {
  source = "../modules/network/network_interface"
  name                   = "${var.NIC_name}fe01"
  resource_group_name    = var.resource_group_name
  location               = var.location
  subnet_id              = module.subnetfe01.id
  public_ip_address_id   = module.public_ip.id

  depends_on = [
    module.subnetfe01
  ]
}

module "file_server" {
  source = "../modules/windows_instance"
  name                             = var.fsvr_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  admin_username                   = "azureuser"
  admin_password                   = "Azureuser123" 
  network_interface_id             = [module.NICfe01.id]

  depends_on = [
    module.NICfe01
  ]
}

resource "azurerm_virtual_machine_extension" "software" {
  name                 = "install-software"
  virtual_machine_id   = module.file_server.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1 ${module.storage_account.key}; exit 0;"
  }
  SETTINGS
  depends_on = [
    module.file_server
  ]
}

data "template_file" "tf" {
    template = "${file("install.ps1")}"

} 
