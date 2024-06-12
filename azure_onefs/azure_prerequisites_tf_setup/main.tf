terraform {
  required_providers {
    azurerm = {
      version = "~>3.100.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}



resource "azurerm_resource_group" "azurerm_resource_group_onefs_azureGA1" {
  name     = "azure_onefs_azureGA1"
  location = "East US"
}



resource "azurerm_network_security_group" "azurerm_security_group_onefs_azureGA1_int" {
  name                = "azureGA1_internal_nsg"
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.name
}



resource "azurerm_network_security_group" "azurerm_security_group_onefs_azureGA1_ext" {
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.name
   name                = "azureGA1_external_nsg"
}


resource "azurerm_user_assigned_identity" "azurerm_user_assigned_identity_azureGA1_identity1" {
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.name
  name               = "azureGA1_identity1"
}



resource "azurerm_role_assignment" "azurerm_role_assignment_azureGA1_role" {
  scope              = azurerm_resource_group.azurerm_resource_group_onefs_azureGA1.id
  role_definition_id = "/subscriptions/9549873d-54cd-4f6b-4583-ac3c6d976cad/providers/Microsoft.Authorization/roleDefinitions/978e6f6a-e0e0-8935-ae96-600d218f4b0a"   
  principal_id       = azurerm_user_assigned_identity.azurerm_user_assigned_identity_azureGA1_identity1.principal_id
}





