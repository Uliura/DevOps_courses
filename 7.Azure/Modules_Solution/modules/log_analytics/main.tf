resource "azurerm_log_analytics_workspace" "example" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "example" {
  solution_name         = var.log_analytics_solution_name
  workspace_resource_id = azurerm_log_analytics_workspace.example.id
  workspace_name        = azurerm_log_analytics_workspace.example.name
  resource_group_name   = var.resource_group_name
  location              = var.location

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}