variable "resource_group_name" {
  type    = string
  default = "iothub-rg"
}

variable "location" {
  type    = string
  default = "centralindia"
}

variable "storage_account_name" {
  type    = string
  default = "tfstorage23456"
}

variable "storage_container_name" {
  type    = string
  default = "example"
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

variable "file_upload" {
  type = object({

    notifications      = bool
    max_delivery_count = number
    sas_ttl            = string
    lock_duration      = string
    default_ttl        = string
  })
  default = {
    notifications      = "true"
    max_delivery_count = 10
    sas_ttl            = "PT1H"
    lock_duration      = "PT1M"
    default_ttl        = "PT1H"
  }

}

variable "ip_filter_rule" {
  type = map(string)
  default = {
    name    = "ip"
    action  = "Accept"
    ip_mask = "10.0.0.0/31"
  }
}

variable "tags" {
  type = map(string)
  default = {
    purpose = "testing"
  }
}


variable "endpoint" {
  type = map(object({ endpoint_names = string
    batch_frequency_in_seconds = number
    max_chunk_size_in_bytes    = number
  encoding = string }))
  default = {
    "endpoint1" = {
      endpoint_names             = "export"
      batch_frequency_in_seconds = 60
      max_chunk_size_in_bytes    = 10485760
      encoding                   = "Avro"
    }
    
  }
}

variable "routes" {
  type = object({ name = string, source = string, condition = bool, endpoint_names = list(string), enabled = bool })
  default = {
    name           = "export"
    source         = "DeviceMessages"
    condition      = true
    endpoint_names = ["export"]
    enabled        = true
  }
}
variable "fallback_route" {
  type = map(object({
    condition      = bool
    endpoint_names = list(string)
  enabled = bool }))

  default = {
    "fallback_route" = {
      condition      = "true"
      endpoint_names = ["export"]
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
  default = "iotub-pvt-endpoint"
}
