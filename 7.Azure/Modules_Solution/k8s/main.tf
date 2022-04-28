module "resource_group" {
  source = "../modules/resource_group" 
  name     = var.resource_group_name
  location = var.location
}

module "log_analitics" {
  source = "../modules/log_analytics"
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  log_analytics_solution_name      = var.log_analytics_solution_name
  depends_on = [
    module.resource_group
  ]    
}

module "k8s_cluster" {
  source = "../modules/k8s_cluster"

  resource_group_name = var.resource_group_name
  location            = var.location
  log_analytics_workspace_id = module.log_analitics.log_analytics_workspace_id
  depends_on = [
    module.log_analitics
  ]  
}
