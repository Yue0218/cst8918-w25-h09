# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.96.0"
    }
  }
}

# Define providers and their config params
provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {}
}

# Define the resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-h09-YG"
  location = var.region
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = "${var.labelPrefix}h09aks"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  dns_prefix = "${var.labelPrefix}aks"

  kubernetes_version  = "1.31.5"  # Use the latest available version from the previous command

  default_node_pool {
    name = "default"
    node_count = 1
    min_count = 1
    max_count = 3
    vm_size = "Standard_B2s"
    enable_auto_scaling = true
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}