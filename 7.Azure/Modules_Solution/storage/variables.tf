variable "storage_account_name" {
  type        = string
  default = "trfrmfileshafeandblobs"
}

variable "storage_container_name" {
  type        = string
  default = "blobs"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
  default     = "ModulesRG"
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default     = "eastus2"
}

variable "subnet_name" {
  type        = string
  default     = "subnet"
}

variable "vnet_name" {
  type        = string
  default     = "vnet_trfrm"
}

variable "vnet_address_space" {
   default     = [
    "10.0.0.0/16" 
    ]
 }

variable "ip_name" {
  type        = string
  default     = "fePublicIP"
}

variable "NIC_name" {
  type        = string
  default     = "NIC"
}

variable "fsvr_name" {
  type        = string
  default     = "winshara"
}
