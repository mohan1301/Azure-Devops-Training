terraform {
    required_version = ">=1.12"
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">=4.0"
        }
    }

backend "azurerm" {
    resource_group_name = "UCSA-SF"
    storage_account_name = "ucsasf0101"
    container_name = "statefilerepo"
    key = "dev.terraform.tfstate"
}
}


provider "azurerm" {
    features {
    }
subscription_id = "e81eb20e-a2b5-4d15-ba82-c3be207cefc8"
}


