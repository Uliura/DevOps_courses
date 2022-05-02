variable "name" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "size" {
  type        = string
  default     = "Standard_D2ads_v5"
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  type        = string
  default     = "Azureuser123"
}

variable "network_interface_id" {
  type        = list(string)
  
}
# variable "custom_data" {}