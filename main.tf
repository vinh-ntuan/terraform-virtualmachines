resource "azurerm_resource_group" "this" {
  name     = "assessment"
  location = "France Central"
}

resource "azurerm_virtual_network" "this" {
  name                = "assessment-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "assessment-subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "this" {
  name                = "assessment-subnet-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Rule for HTTP
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Rule for HTTPS
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # SSH Rule, dev only
  security_rule {
    name                       = "AllowSSHInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_public_ip" "this" {
  count               = var.vm_count
  name                = "assessment-vm.pip-${count.index}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  count               = var.vm_count
  name                = "assessment-vm-nic-${count.index}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  count                 = var.vm_count
  name                  = "assessment-vm-${count.index}"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.vm_configs[count.index].size
  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = random_password.vm_password[count.index].result

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_configs[count.index].image.publisher
    offer     = var.vm_configs[count.index].image.offer
    sku       = var.vm_configs[count.index].image.sku
    version   = var.vm_configs[count.index].image.version
  }
}