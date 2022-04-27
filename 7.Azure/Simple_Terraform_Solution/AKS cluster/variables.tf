variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "RG location in Azure"
}

variable "log_analytics_solution_name" {
  type        = string
  description = "Log analytics solution name in Azure"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log analytics workspace name in Azure"
}

variable "k8s_cluster_name" {
  type        = string
  description = "cluster name in Azure"
}

variable "k8s_dns_prefix_name" {
  type        = string
  description = "DNS prefix for k8s cluster in Azure"
}