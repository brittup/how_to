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


resource "azurerm_resource_group" "azurerm_resource_group_onefs_azure_ga1" {
  name     = "azure_onefs_azure_ga1"
  location = "East US"
}


resource "azurerm_network_security_group" "azurerm_security_group_onefs_azure_ga1_int" {
  name                = "azure_ga1_internal_nsg"
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.name
}


resource "azurerm_network_security_group" "azurerm_security_group_onefs_azure_ga1_ext" {
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.name
   name                = "azure_ga1_external_nsg"
}


resource "azurerm_user_assigned_identity" "azurerm_user_assigned_identity_azure_ga1_identity1" {
  location            = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.location
  resource_group_name = azurerm_resource_group.azurerm_resource_group_onefs_azure_ga1.name
  name               = "azure_ga1_identity1"
}



#role definition will be obtained from the IAM role created with require privilege, not part of tf yet


resource "azurerm_role_assignment" "azurerm_role_assignment_azure_ga1_role" {
  scope              = "/subscriptions/9549873d-89kl-4f6b-4829-ac3c6d976cad"
  role_definition_id = "/subscriptions/9549873d-89kl-4f6b-4829-ac3c6d976cad/providers/Microsoft.Authorization/roleDefinitions/978e6f6a-p09l-496pl-ae96-600d218f4b0a"   
  principal_id       = azurerm_user_assigned_identity.azurerm_user_assigned_identity_azure_ga1_identity1.principal_id
}




