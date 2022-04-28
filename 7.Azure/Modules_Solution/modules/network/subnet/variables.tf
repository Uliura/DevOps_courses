variable "name" {
  type        = string
}

variable "network_name" {
  type        = string
}

variable "address_prefixes" {
  type        = list(string)
  default     = [
    "10.0.1.0/24"
    ]
}

variable "resource_group_name" {
  type        = string
}