variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
  default     = "appgtwresourcegroup"
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "westeurope"
}

variable "vnet_name" {
  type        = string
  default     = "appgtwvnet"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_service_plan_name" {
  default = "trfappplan"
}

variable "app_service_name" {

  default     = "gekarandomnameapp"
}

variable "subnet_name" {

  default     = "subnet"
}

variable "ip_name" {

  default     = "appgtwpublicip"
}

variable "app_gateway_service_name" {

  default     = "trfAppGtw"
}

