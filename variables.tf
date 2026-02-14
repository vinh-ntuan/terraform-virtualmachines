variable "vm_count" {
  type        = number
  description = "Number of VMs to create (2-100)"
  default     = 3
  validation {
    condition     = var.vm_count >= 2 && var.vm_count <= 100
    error_message = "The number of VMs must be between 2 and 100."
  }
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_configs" {
  type = list(object({
    size = string
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
  description = "List of VM configurations"

  validation {
    condition     = length(var.vm_configs) == var.vm_count
    error_message = "The number of VM configurations must be equal to var.vm_count"
  }

  default = [
    {
      size = "Standard_B1s"
      image = {
        publisher = "Debian"
        offer     = "debian-12"
        sku       = "12-gen2"
        version   = "latest"
      }
    },
    {
      size = "Standard_B1s"
      image = {
        publisher = "Debian"
        offer     = "debian-12"
        sku       = "12-gen2"
        version   = "latest"
      }
    },
    {
      size = "Standard_B1s"
      image = {
        publisher = "Debian"
        offer     = "debian-12"
        sku       = "12-gen2"
        version   = "latest"
      }
    },
  ]
}