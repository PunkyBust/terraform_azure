variable "resource_group_name" {
    type = string
    description = "Name of our Resource Group"
    default = "PunkyBust"
}

variable "location_name" {
    type = string
    description = "Name of our Location"
    default = "francecentral"
}

variable "domain_name_label" {
    type = string
    description = "Name of our Domain Label"
    default = "punkybustterraformdns"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}