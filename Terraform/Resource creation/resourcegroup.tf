resource "azurerm_resource_group" "name" {
  name     = "ucrg01"
  location = "eastus"
}
#name is locally defined and can be used as a reference in other resource definitions. 
#It is not a reserved keyword.
