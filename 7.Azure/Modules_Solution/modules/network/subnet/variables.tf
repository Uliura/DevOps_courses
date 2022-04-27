variable "name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "network_name" {
  type        = string
}

variable "address_prefixes" {
  type        = list(string)
  default     = ["10.0.0.0/24"]
}