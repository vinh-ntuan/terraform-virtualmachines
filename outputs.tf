output "vm_details" {
  value = [
    for i in range(var.vm_count) : {
      name           = azurerm_linux_virtual_machine.this[i].name
      admin_user     = azurerm_linux_virtual_machine.this[i].admin_username
      admin_password = azurerm_linux_virtual_machine.this[i].admin_password
      public_ip      = azurerm_linux_virtual_machine.this[i].public_ip_address
      private_ip     = azurerm_linux_virtual_machine.this[i].private_ip_address
    }
  ]
  sensitive = true
}