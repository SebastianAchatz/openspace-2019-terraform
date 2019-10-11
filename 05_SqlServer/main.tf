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

resource "azurerm_application_insights" "osp_webapp_appinsights" {
  name                = "ospterraform2019-appinsights"
  location            = "${azurerm_resource_group.osp_rg.location}"
  resource_group_name = "${azurerm_resource_group.osp_rg.name}"
  application_type    = "web"
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
    "SOME_KEY"                               = "some-value"
    "ApplicationInsights:InstrumentationKey" = "${azurerm_application_insights.osp_webapp_appinsights.instrumentation_key}"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

resource "azurerm_resource_group" "osp_rg_sql" {
  name     = "OpenSpace2019TerraformSQL"
  location = "westeurope"
}

resource "azurerm_sql_server" "osp_sql_server" {
  name                = "ospterraformsqlserver"
  resource_group_name = "${azurerm_resource_group.osp_rg_sql.name}"
  location            = "${azurerm_resource_group.osp_rg_sql.location}"

  version                      = "12.0"
  administrator_login          = "ospterraformadmin"
  administrator_login_password = "thisIsMySecret"

  lifecycle {
    ignore_changes = [
      #ignore changes to sql admin password
      administrator_login_password
    ]
  }
}

resource "azurerm_sql_database" "osp_sql_db" {
  name                = "ospterraformsqldb"
  resource_group_name = "${azurerm_resource_group.osp_rg_sql.name}"
  location            = "${azurerm_resource_group.osp_rg_sql.location}"
  server_name         = "${azurerm_sql_server.osp_sql_server.name}"
}
