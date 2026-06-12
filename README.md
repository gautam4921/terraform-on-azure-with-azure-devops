# Terraform on Azure with Azure IaC DevOps for Terraform Project

1. Implement IaC usecases with Terraform on Azure cloud using Azure DevOps
2. Implement Azure Build Pipelines (Continuous Integration Pipelines)
3. Implement Azure Release Pipelines (Continuous Delivery Pipelines)
4. [Github SSH Connection](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/about-ssh)

Issues Faced while building Terraform cd pipeline for dev environment 
# Terraform State Storage to Azure Storage Container (Values will be taken from Azure DevOps) you can leave blank also 
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
    resource_group_name  = "terraform-storage-rg"
    storage_account_name = "terraformstate11062026"
    container_name       = "terraformtfstate2026"
    key                  = "dev-terraform.tfstate"
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


#############################
Generate Terraform Providers lock for multiple platforms 
terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64


Output will be like this 
D:\demo-repos\terraform-on-azure-with-azure-devops\Azure-IaC-DevOps\Git-Repo-Files\terraform-manifests>terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64
- Fetching hashicorp/random 3.5.1 for windows_amd64...
- Retrieved hashicorp/random 3.5.1 for windows_amd64 (signed by HashiCorp)
- Fetching hashicorp/azurerm 4.76.0 for windows_amd64...
- Retrieved hashicorp/azurerm 4.76.0 for windows_amd64 (signed by HashiCorp)
- Fetching hashicorp/random 3.5.1 for darwin_amd64...
- Retrieved hashicorp/random 3.5.1 for darwin_amd64 (signed by HashiCorp)
- Fetching hashicorp/azurerm 4.76.0 for darwin_amd64...
- Retrieved hashicorp/azurerm 4.76.0 for darwin_amd64 (signed by HashiCorp)
- Fetching hashicorp/azurerm 4.76.0 for linux_amd64...
- Retrieved hashicorp/azurerm 4.76.0 for linux_amd64 (signed by HashiCorp)
- Fetching hashicorp/random 3.5.1 for linux_amd64...
- Retrieved hashicorp/random 3.5.1 for linux_amd64 (signed by HashiCorp)
- Obtained hashicorp/azurerm checksums for windows_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file
- Obtained hashicorp/azurerm checksums for darwin_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file
- Obtained hashicorp/azurerm checksums for linux_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file
- Obtained hashicorp/random checksums for windows_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file
- Obtained hashicorp/random checksums for darwin_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file
- Obtained hashicorp/random checksums for linux_amd64; This was a new provider and the checksums for this platform are now tracked in the lock file

Success! Terraform has updated the lock file.

Review the changes in .terraform.lock.hcl and then com


##
Generate Terraform Providers lock for multiple platforms and put in terraform manifest folder 
terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64


###########################
Pipeline error during terraform init  

‌Error: ‌retrieving Storage Account (Subscription: &quot;cd6208f9-14cc-4d2d-a201-43ec9eeda060&quot;‌
2026-06-12T04:40:17.6489189Z ‌│‌ ‌Resource Group Name: &quot;terraform-storage-rg&quot;‌
2026-06-12T04:40:17.6490319Z ‌│‌ ‌Storage Account Name: &quot;terraformstate11062026&quot;): authorizing request: ManagedIdentityAuthorizer: failed to request token from metadata endpoint: received HTTP status 400 with body: {&quot;error&quot;:&quot;invalid_request&quot;,&quot;error_description&quot;:&quot;Identity not found&quot;}‌


terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-storage-rg"
    storage_account_name = "terraformstate11062026"
    container_name       = "terraformtfstate2026"
    key                  = "dev-terraform.tfstate"
  }
}



##########################################################################################

CD pipeline error during terraform init  
Error Log :-
Initializing the backend...‌
2026-06-11T16:18:47.0569177Z 
2026-06-11T16:18:47.0596249Z ‌╷‌
2026-06-11T16:18:47.0605809Z ‌│‌ ‌Error: ‌retrieving Storage Account (Subscription: &quot;cd6208f9-14cc-4d2d-a201-43ec9eeda060&quot;‌
2026-06-11T16:18:47.0625626Z ‌│‌ ‌Resource Group Name: &quot;terraform-storage-rg&quot;‌
2026-06-11T16:18:47.0648983Z ‌│‌ ‌Storage Account Name: &quot;terraformstate11062026&quot;): authorizing request: ManagedIdentityAuthorizer: failed to request token from metadata endpoint: received HTTP status 400 with body: {&quot;error&quot;:&quot;invalid_request&quot;,&quot;error_description&quot;:&quot;Identity not found&quot;}‌
2026-06-11T16:18:47.0665199Z ‌│‌ 


Storage Account Name: &quot;terraformstate11062026&quot;): authorizing request: ManagedIdentityAuthorizer: failed to request token from metadata endpoint: received HTTP status 400 with body: {&quot;error&quot;:&quot;invalid_request&quot;,&quot;error_description&quot;:&quot;Identity not found&quot;}‌

Solution Found : 
Azure Resource Manager using App registration (automatic),This means your service connection is Service Principal (Automatic), NOT Managed Identity.So the service connection itself is fine.

Your pipeline log shows:
terraform init
...
-backend-config=use_msi=true

Since the service connection is Service Principal-based, use_msi=true is being injected by either:

A setting in the TerraformTaskV2 task
Pipeline variables (ARM_USE_MSI)
A bug/behavior in the older TerraformTaskV2 extension


How to fix -backend-config=use_msi=true in terraform init 
To fix -backend-config=use_msi=true, you need to find what is injecting it. Your Terraform code and service connection are not the cause.


Correct for Classic Release Pipeline

In the Azure CLI task:

Script Type: Bash

Script Location: Inline Script

Inline Script:

Do not paste any YAML into the script box.

cd "$(System.DefaultWorkingDirectory)/_Terraform continious integration CI Pipeline/terraform-manifests"

terraform init \
  -backend-config="resource_group_name=terraform-storage-rg" \
  -backend-config="storage_account_name=terraformstate11062026" \
  -backend-config="container_name=terraformtfstate2026" \
  -backend-config="key=dev-terraform.tfstate"

####################################################################################################
Location used in Terraform : East US which needs to be changed in terraform.tfvars
Vm size used : Standard_B2as_v2 ,(2 vcpus, 8 GiB memory) : which needs to be changed in dev.tfvars,prod.tfvars,qa.tfvars,stage.tf.var
