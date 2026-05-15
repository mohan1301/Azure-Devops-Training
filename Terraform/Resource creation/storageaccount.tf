resource "azurerm_storage_account" "resourcesa" {
  name                     = "ucrg01sa1980"
  location = azurerm_resource_group.name.location
  resource_group_name      = azurerm_resource_group.name.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}