resource "azurerm_resource_group" "ucrg" {
  name = var.rgname
  location = var.location
  tags = {
    Name = "DemoRG"
    Owner = "Mohan"
    environment = "TST"
  }
}

resource "azurerm_service_plan" "ucasp" {
  # resource_group_name = var.rgname
  resource_group_name = azurerm_resource_group.ucrg.name
  name = var.asp
  location = azurerm_resource_group.ucrg.location
  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "ucwebapp" {
  name = var.webapp
  location = azurerm_resource_group.ucrg.location
  resource_group_name = azurerm_resource_group.ucrg.name
  service_plan_id = azurerm_service_plan.ucasp.id
  site_config {
    always_on = false
  }
}
