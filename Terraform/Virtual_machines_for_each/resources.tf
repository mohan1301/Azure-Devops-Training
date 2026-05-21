resource "azurerm_resource_group" "rg" {
  for_each = var.environments
  name = "rg-${each.key}"
  location = var.location
  lifecycle {
    prevent_destroy = false # This command will ignore if any destroy action rans
    ignore_changes = [ tags ] # This will neglect the changes made to specific parameter. And if the user made some change to vm size in portal to B2ms and if we run the script... it will ignore. But, if we update the vm size to B3ms, terraform will update the vm size to B3ms. So, update to new state works. But, it will not come back to Desired state in state file.
  }
}

resource "azurerm_virtual_network" "vnet" {
  for_each = var.environments
  name = "vnet-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
#   address_space = ["10.1.0.0/16", "10.2.0.0/16", "10.3.0.0/16"]
  address_space = [
    "10.${each.key == "dev" ? 1 : each.key == "qa" ? 2 : 3}.0.0/16"
  ]
  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet" "subnet" {
    for_each = var.environments
    name = "subnet_${each.key}"
    resource_group_name = azurerm_resource_group.rg[each.key].name
    virtual_network_name = azurerm_virtual_network.vnet[each.key].name
    address_prefixes = [
        "10.${each.key == "dev" ? 1: each.key == "qa" ? 2 : 3}.1.0/24"
    ]
    depends_on = [ azurerm_virtual_network.vnet ]
}

# private_ip
# public_ip

resource "azurerm_public_ip" "pubip" {
  for_each = var.environments
  name = "pubip-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "nic" {
  for_each = var.environments
  name = "nic-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  ip_configuration {
    name = "ip-${each.key}"
    subnet_id = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pubip[each.key].id
  }
  depends_on = [ azurerm_public_ip.pubip, azurerm_subnet.subnet ]
}

resource "azurerm_linux_virtual_machine" "vm1" {
  for_each = var.environments
  name = "vm-${each.key}"
  location = var.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  size = each.value
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  admin_username = var.adminusername
  disable_password_authentication = true
  source_image_reference {
    publisher = "Canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }
  admin_ssh_key {
    username = var.adminusername
    public_key = file(var.SSH_Key)
  }
  os_disk {
    name = "osdisk-${each.key}"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  depends_on = [azurerm_network_interface.nic]
}

resource "azurerm_resource_group" "countdemo"{
    count = 2
    name = "count-rg-${count.index}"
    location = var.location
}