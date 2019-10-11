provider "azurerm" {
  version = ">= 1.34.0"
}

resource "azurerm_resource_group" "osp_rg" {
  name     = "OpenSpace2019Terraform"
  location = "westeurope"

  tags = {
    environment = "develop"
  }
}
