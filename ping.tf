resource "terraform_data" "round_robin_ping" {
  count = var.vm_count

  triggers_replace = azurerm_linux_virtual_machine.this[*].id

  provisioner "local-exec" {
    command = <<EOT
      SOURCE_VM_USER='${azurerm_linux_virtual_machine.this[count.index].admin_username}'
      SOURCE_VM_PASSWORD='${azurerm_linux_virtual_machine.this[count.index].admin_password}'
      SOURCE_VM_IP=${azurerm_linux_virtual_machine.this[count.index].public_ip_address}
      TARGET_VM_IP=${azurerm_linux_virtual_machine.this[(count.index + 1) % var.vm_count].private_ip_address}
      echo "VM-${count.index} pinging $TARGET_VM_IP..." > ping_result_${count.index}.txt
      sshpass -p "$SOURCE_VM_PASSWORD" ssh "$SOURCE_VM_USER@$SOURCE_VM_IP" "ping $TARGET_VM_IP -c1" || echo "Ping Failed" >> ping_result_${count.index}.txt
    EOT
  }

  depends_on = [azurerm_linux_virtual_machine.this]
}

data "local_file" "ping_results" {
  count      = var.vm_count
  filename   = "ping_result_${count.index}.txt"
  depends_on = [terraform_data.round_robin_ping]
}

output "ping_results" {
  value = {
    for i in range(var.vm_count) :
    "vm-${i}-to-next" => data.local_file.ping_results[i].content
  }
}