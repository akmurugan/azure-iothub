variable "resource_group_name" {
  type    = string
  default = "iothub-rg"
}

variable "location" {
  type    = string
  default = "westus"
}

variable "base_name" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "testiot"
}

variable "sku" {
  type = object(
    {
      name     = string
      capacity = number
    }
  )
  default = {
    name     = "S1"
    capacity = "1"
  }

}
