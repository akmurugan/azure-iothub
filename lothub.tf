provider "azurerm" {
  features {}
}

data "azurerm_subnet" "this" {
  name                 = "tfsubnet"
  virtual_network_name = "tfvnt"
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


  file_upload {
    connection_string  = data.azurerm_storage_account.storage_account.primary_blob_connection_string
    container_name     = data.azurerm_storage_container.container.name
    notifications      = var.file_upload.notifications
    max_delivery_count = var.file_upload.max_delivery_count
    sas_ttl            = var.file_upload.sas_ttl
    lock_duration      = var.file_upload.lock_duration
    default_ttl        = var.file_upload.default_ttl
  }

  ip_filter_rule {
    name    = var.ip_filter_rule.name
    action  = var.ip_filter_rule.action
    ip_mask = var.ip_filter_rule.ip_mask
  }
  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = data.azurerm_storage_account.storage_account.primary_blob_connection_string
    name                       = var.endpoint.endpoint1.endpoint_names
    batch_frequency_in_seconds = var.endpoint.endpoint1.batch_frequency_in_seconds
    max_chunk_size_in_bytes    = var.endpoint.endpoint1.max_chunk_size_in_bytes
    container_name             = data.azurerm_storage_container.container.name
    encoding                   = var.endpoint.endpoint1.encoding
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }
  route {
    name           = var.routes.name
    source         = var.routes.source
    condition      = var.routes.condition
    endpoint_names = var.routes.endpoint_names
    enabled        = var.routes.enabled
  }

  fallback_route {
    condition      = var.fallback_route.fallback_route.condition
    endpoint_names = var.fallback_route.fallback_route.endpoint_names
    enabled        = var.fallback_route.fallback_route.enabled

  }

  tags = var.tags

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
resource "azurerm_iothub_consumer_group" "consumer_group" {
  name                   = "${var.base_name}-ihc-${var.name}"
  iothub_name            = azurerm_iothub.iothub.name
  eventhub_endpoint_name = var.eventhub_endpoint_name
  resource_group_name    = var.resource_group_name
}
