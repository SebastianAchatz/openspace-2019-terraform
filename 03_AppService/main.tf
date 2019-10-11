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

resource "azurerm_app_service_plan" "osp_appservice_plan" {
  name                = "osp_appservice_plan"
  location            = "${azurerm_resource_group.osp_rg.location}"
  resource_group_name = "${azurerm_resource_group.osp_rg.name}"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "osp_webapp" {
  name                = "ospterraform2019"
  location            = "${azurerm_resource_group.osp_rg.location}"
  resource_group_name = "${azurerm_resource_group.osp_rg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.osp_appservice_plan.id}"

  site_config {
    dotnet_framework_version = "v4.0"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }
}
