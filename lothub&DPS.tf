provider "azurerm" {
 
  features {}
}

data "azurerm_subnet" "this" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_storage_account" "storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_container" "container" {
  name                 = var.storage_container_name
  storage_account_name = data.azurerm_storage_account.storage_account.name
}

resource "azurerm_iothub" "iothub" {
  name                = "${var.base_name}-iot-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
  }

  public_network_access_enabled = "false"

  dynamic "file_upload" {
    for_each = var.file_upload
    content {

      connection_string  = data.azurerm_storage_account.storage_account.primary_blob_connection_string
      container_name     = data.azurerm_storage_container.container.name
      notifications      = file_upload.value.notifications
      max_delivery_count = file_upload.value.max_delivery_count
      sas_ttl            = file_upload.value.sas_ttl
      lock_duration      = file_upload.value.lock_duration
      default_ttl        = file_upload.value.default_ttl
    }
  }

  dynamic "ip_filter_rule" {
    for_each = var.ip_filter_rule
    content {
      name    = ip_filter_rule.value.name
      action  = ip_filter_rule.value.action
      ip_mask = ip_filter_rule.value.ip_mask
    }
  }

  dynamic "endpoint" {
    for_each = var.endpoint
    content {

      type                       = "AzureIotHub.StorageContainer"
      connection_string          = data.azurerm_storage_account.storage_account.primary_blob_connection_string
      name                       = endpoint.value.endpoint_names
      batch_frequency_in_seconds = endpoint.value.batch_frequency_in_seconds
      max_chunk_size_in_bytes    = endpoint.value.max_chunk_size_in_bytes
      container_name             = data.azurerm_storage_container.container.name
      encoding                   = "Avro"
      file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
    }
  }

  dynamic "route" {
    for_each = var.routes
    content {
      name           = route.value.name
      source         = route.value.source
      condition      = route.value.condition
      endpoint_names = route.value.endpoint_names
      enabled        = route.value.enabled
    }
  }

  dynamic "fallback_route" {
    for_each = var.fallback_route
    content {
      condition      = fallback_route.value.condition
      endpoint_names = fallback_route.value.endpoint_names
      enabled        = fallback_route.value.enabled
    }
  }
  tags = var.tags
}


resource "azurerm_iothub_shared_access_policy" "access_policy" {
  for_each            = var.iothub_shared_access_policy
  name                = var.iothub_shared_access_policy.iothub_policy.name
  resource_group_name = var.resource_group_name
  iothub_name         = azurerm_iothub.iothub.name

  registry_read  = each.value.registry_read
  registry_write = each.value.registry_write

}

resource "azurerm_iothub_consumer_group" "consumer_group" {
  name                   = "${var.base_name}-ihc-${var.name}"
  iothub_name            = azurerm_iothub.iothub.name
  eventhub_endpoint_name = var.eventhub_endpoint_name
  resource_group_name    = var.resource_group_name
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

resource "azurerm_iothub_dps_shared_access_policy" "access_policy" {
  for_each            = var.dps_shared_access_policy
  name                = var.dps_shared_access_policy.dps_policy.name
  resource_group_name = var.resource_group_name
  iothub_dps_name     = azurerm_iothub_dps.iothub_dps.name

  enrollment_write  = each.value.enrollment_write
  enrollment_read   = each.value.enrollment_read
  registration_read = each.value.registration_read
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.this.id

  private_service_connection {
    name                           = azurerm_iothub.iothub.name
    private_connection_resource_id = azurerm_iothub.iothub.id
    subresource_names              = ["iothub"]
    is_manual_connection           = false
  }
}