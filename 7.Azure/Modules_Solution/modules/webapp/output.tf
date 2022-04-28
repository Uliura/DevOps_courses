output "fqdns" {
  value = azurerm_app_service.webapp.default_site_hostname
}