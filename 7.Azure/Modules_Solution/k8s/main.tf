module "resource_group" {
  source = "../modules/resource_group"  
}

module "log_analitics" {
  source = "../modules/log_analytics"
  
}

module "k8s_cluster" {
  source = "../modules/k8s_cluster"
  
}
