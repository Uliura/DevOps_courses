module "resource_group" {
  source = "../modules/resource_group"  
}

module "storage_account" {
  source = "../modules/storage"
  
}

module "container" {
  source = "../modules/storage_container"
  
}

module "file_server" {
  source = "../modules/windows_instance"
  
}
