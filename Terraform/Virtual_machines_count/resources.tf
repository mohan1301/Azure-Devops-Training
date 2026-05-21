resource "azurerm_resource_group" "rg" {
  name     = "countrg"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "countdemo98765"
  location                 = var.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_replication_type = "LRS"
  account_tier             = "Standard"
  lifecycle {
    prevent_destroy = false
    ignore_changes  = [tags]
  }
}

resource "azurerm_virtual_network" "Vnet" {
  name                = "CountVnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "CountSubnet"
  virtual_network_name = azurerm_virtual_network.Vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "Countnsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "ssh"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "publicip" {
  count               = var.vm_count
  name                = "publicip-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsgas" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = var.vm_count
  name                            = "vm-${count.index}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  network_interface_ids           = [azurerm_network_interface.nic[count.index].id]
  size                            = var.vm-size
  disable_password_authentication = true
  admin_username                  = var.adminusername
  admin_ssh_key {
    username   = var.adminusername
    public_key = file(var.SSH_Key)
  }
  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  lifecycle {
    prevent_destroy = false
    # ignore_changes  = [size]
  }
}
