terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.41.0"
    }
    random ={}

  }
}

#useful blog
#https://github.com/JustinGrote/terraform-azurerm-azure-function-powershell/blob/master/main.tf
#https://adrianhall.github.io/typescript/2019/10/23/terraform-functions/

provider "azurerm" {
    features {}
    subscription_id = var.subscriptionid
}

resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-${var.environment}"
    location = var.location
}

resource "azurerm_storage_account" "storage" {
    name = random_string.storage_name.result
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_storage_container" "deployments" {
    name = "function-releases"
    storage_account_name = azurerm_storage_account.storage.name
    container_access_type = "private"
}

# resource "azurerm_storage_blob" "appcode" {
#     name = "functionapp.zip"
#     storage_account_name = azurerm_storage_account.storage.name
#     storage_container_name = azurerm_storage_container.deployments.name
#     type = "Block"
#     source = var.functionapp
# }

# data "azurerm_storage_account_sas" "sas" {
#     connection_string = azurerm_storage_account.storage.primary_connection_string
#     https_only = true
#     start = "2019-01-01"
#     expiry = "2021-12-31"
#     resource_types {
#         object = true
#         container = false
#         service = false
#     }
#     services {
#         blob = true
#         queue = false
#         table = false
#         file = false
#     }
#     permissions {
#         read = true
#         write = false
#         delete = false
#         list = false
#         add = false
#         create = false
#         update = false
#         process = false
#     }
# }

resource "azurerm_app_service_plan" "asp" {
    name = "${var.prefix}-plan"
    resource_group_name = azurerm_resource_group.rg.name
    location = var.location
    kind = "FunctionApp"
    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

resource "azurerm_function_app" "functions" {
    name = "${var.prefix}-${var.environment}"
    location = var.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id
    storage_account_name       = azurerm_storage_account.storage.name
    storage_account_access_key = azurerm_storage_account.storage.primary_access_key
    version = "~2"
    identity {
      type = "SystemAssigned"
    }
    app_settings = {
       "FUNCTIONS_WORKER_RUNTIME"       = "powershell"
    }
}