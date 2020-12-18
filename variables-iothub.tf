variable "resource_group_name" {
  type    = string
  default = "iot-rg"
}

variable "location" {
  type    = string
  default = "eastus"
}
variable "subnet_name" {
  type    = string
  default = "arunsubnet"
}
variable "virtual_network_name" {
  type    = string
  default = "virtualNetwork1"
}

variable "storage_account_name" {
  type    = string
  default = "arunstg"
}

variable "storage_container_name" {
  type    = string
  default = "example"
}

variable "base_name" {
  type    = string
  default = "arun"
}

variable "name" {
  type    = string
  default = "testiot"
}

variable "sku" {
  type = object({ name = string, capacity = number })
  default = {
    name     = "S1"
    capacity = "1"
  }

}

variable "file_upload" {
  type = map(object({ notifications = bool, max_delivery_count = number, sas_ttl = string, lock_duration = string, default_ttl = string }))
  default = {
    file_upload = {
      notifications      = "true"
      max_delivery_count = 10
      sas_ttl            = "PT1H"
      lock_duration      = "PT1M"
      default_ttl        = "PT1H"
    }
  }
}

variable "ip_filter_rule" {
  type = map(object({ name = string, action = string, ip_mask = string }))
  default = {
    ip_filter_rule = {
      name    = "ip"
      action  = "Accept"
      ip_mask = "10.0.0.0/31"
    }
  }
}

variable "tags" {
  type = map(string)
  default = {
    purpose = "testing"
  }
}

variable "endpoint" {
  type = map(object({ endpoint_names = string, batch_frequency_in_seconds = number, max_chunk_size_in_bytes = number }))
  default = {
    endpoint = {
      endpoint_names             = "export"
      batch_frequency_in_seconds = 60
      max_chunk_size_in_bytes    = 10485760
    }
  }
}

variable "routes" {
  type = map(object({ name = string, source = string, condition = bool, endpoint_names = list(string), enabled = bool }))
  default = {
    route = {
      name           = "export"
      source         = "DeviceMessages"
      endpoint_names = ["export"]
      condition      = true
      enabled        = true
    }
  }
}
variable "fallback_route" {
  type = map(object({ condition = bool, endpoint_names = list(string), enabled = bool }))
  default = {
    "fallback_route" = {
      endpoint_names = ["export"]
      condition      = "true"
      enabled        = "true"
    }
  }
}

variable "eventhub_endpoint_name" {
  type    = string
  default = "events"
}

variable "private_endpoint" {
  type    = string
  default = "sysfore3"
}
variable "iothub_shared_access_policy" {
  type = map(object({ name = string, registry_read = bool, registry_write = bool }))
  default = {
    "iothub_policy" = {
      name           = "iothubpolicy"
      registry_read  = true
      registry_write = true

    }
  }
}

variable "dps_shared_access_policy" {
  type = map(object({ name = string, enrollment_write = bool, enrollment_read = bool, registration_read = bool }))
  default = {
    "dps_policy" = {
      name              = "dpspolicy"
      enrollment_write  = "true"
      enrollment_read   = "true"
      registration_read = "true"

    }
  }
}