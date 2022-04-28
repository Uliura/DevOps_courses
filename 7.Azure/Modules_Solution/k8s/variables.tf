variable "log_analytics_solution_name" {
  type        = string
  default     = "Containers"
}

variable "log_analytics_workspace_name" {
  type        = string
  default = "logworkgekaname"
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
  default = "aksTrfrmGroup"
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
  default = "eastus2"

}