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


