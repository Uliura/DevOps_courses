output "app_gtw_ip" {
  value = azurerm_public_ip.gateway_ip.ip_address
}

output "app_gtw_url" {
  value = azurerm_public_ip.gateway_ip.fqdn
}