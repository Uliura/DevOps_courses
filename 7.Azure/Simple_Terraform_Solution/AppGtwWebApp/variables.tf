variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "RG location in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name in Azure"
}

variable "app_service_name" {
  type        = string
  description = "App Service name in Azure"
}

variable "vnet_service_name" {
  type        = string
  description = "VNet Service name in Azure"
}

variable "public_ip_service_name" {
  type        = string
  description = "Public IP Service name in Azure"
}

variable "domain_name" {
  type        = string
  description = "Public domain name in Azure"
}

variable "app_gateway_service_name" {
  type        = string
  description = "App Gatewey name in Azure"
}

