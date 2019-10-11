provider "azurerm" {
  version = ">= 1.34.0"
}

locals {
  resource_group_name     = "osptfremotebackendrg"
  resource_group_location = "westeurope"
  storage_account_name    = "osptfremoteback"
  container_name          = "tfstate"
}


resource "azurerm_resource_group" "osp_tf_backend" {
  name     = "${local.resource_group_name}"
  location = "${local.resource_group_location}"

  tags = {
    service = "tfstate"
  }
}

resource "azurerm_storage_account" "osp_tf_backend_storage" {
  name                     = "${local.storage_account_name}"
  resource_group_name      = "${azurerm_resource_group.osp_tf_backend.name}"
  location                 = "${azurerm_resource_group.osp_tf_backend.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    service = "tfstate"
  }
}

resource "azurerm_storage_container" "osp_tf_backend_storage_container" {
  name                  = "${local.container_name}"
  storage_account_name  = "${azurerm_storage_account.osp_tf_backend_storage.name}"
  container_access_type = "private"
}

output "storage_access_key" {
  value = "${azurerm_storage_account.osp_tf_backend_storage.primary_access_key}"
}
