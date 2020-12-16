provider "azurerm" {
  features {}
}

resource "azurerm_iothub_dps" "iothub_dps" {
  name                = "${var.base_name}-dps-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
  }
}

resource "azurerm_iothub_dps_certificate" "cer" {
  name                = "${var.base_name}-cer-${var.name}"
  resource_group_name = var.resource_group_name
  iot_dps_name        = azurerm_iothub_dps.iothub_dps.name
  certificate_content = filebase64("fgintermediate.cer")
}