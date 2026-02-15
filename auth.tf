resource "random_password" "vm_password" {
  count   = var.vm_count
  length  = 16
  special = false
}