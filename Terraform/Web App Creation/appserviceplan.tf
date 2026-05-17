resource "azurerm_service_plan" "asp_name" {
  name                = "asp-name"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
#   kind                = "Linux"
#   reserved            = true

  # Newer azurerm provider expects sku_name and os_type instead of a sku block
  sku_name = "S1"
  os_type  = "Linux"
}

resource "azurerm_linux_web_app" "linuxwebapp" {
  name                = "linuxwebapp01"
  location            = azurerm_service_plan.asp_name.location
  resource_group_name = azurerm_service_plan.asp_name.resource_group_name
  service_plan_id     = azurerm_service_plan.asp_name.id

  site_config {
  }
}

#Arguments are variables that are used to define or create the resource
#Attributes are variables that are created after the creation of the resources which are helpful in exporting outputs
# So, Attributes cannot be written in these files under resource blocks since they exist after the resource creation

