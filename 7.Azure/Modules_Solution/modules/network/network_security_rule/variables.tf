variable "name" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "network_security_group_name" {
  type        = string
}

variable "priority " {}
variable "direction" {}
variable "access" {}
variable "protocol" {}
variable "source_port_range" {}
variable "destination_port_range" {}
variable "source_address_prefix " {}
variable "destination_address_prefix" {}
