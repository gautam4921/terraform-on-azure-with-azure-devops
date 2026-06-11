# Terraform Block
terraform {
  required_version = ">=1.15" # Terraform Cli Version
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.9" # Terraform Azure Provider Version
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1" # Terraform Random Provider Version
    }
  }

  # Terraform State Storage to Azure Storage Container (Values will be taken from Azure DevOps)
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    # When above feature flag is set, Terraform will skip checking for any Resources within the Resource Group and
    # delete this using the Azure API directly (which will clear up any nested resources).  
  }

}

