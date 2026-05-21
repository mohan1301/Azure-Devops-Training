terraform {
    required_version = ">=1.12"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">=4.0"
        }
    }
}
provider "azurerm" {
    features {
    }
subscription_id = "e81eb20e-a2b5-4d15-ba82-c3be207cefc8"
}


