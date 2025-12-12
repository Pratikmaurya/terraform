terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate21215"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group - The container for all my resources
resource "azurerm_resource_group" "rg" {
  name     = "rg-pratik-learning-dev"
  location = "Canada Central"
}

# 2. App Service Plan - The "Hardware" powering my app
# Clap yourself moment: I use "Standard" (S1) because Stage 4 requires "Deployment Slots".
# Free/Basic tiers do not support Blue/Green deployment.
resource "azurerm_service_plan" "plan" {
  name                = "asp-pratik-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1" 
}

# 3. Random String - To make sure my URL is unique (e.g., app-pratik-x9z2.azurewebsites.net)
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

# 4. The Web App - The actual website
resource "azurerm_linux_web_app" "webapp" {
  name                = "app-pratik-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    application_stack {
      dotnet_version = "6.0" # Or 7.0/8.0 depending on your project
    }
  }
}

# Output the URL so we know where to go later
output "webapp_url" {
  value = azurerm_linux_web_app.webapp.default_hostname
}