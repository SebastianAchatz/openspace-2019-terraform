provider "azurerm" {
  version = ">= 1.34.0"
}

variable "sql_server_name" {
  type = string
}

variable "sql_db_name" {
  type = string
}

locals {
  webapp_rg_name              = "OpenSpace2019Terraform"
  webapp_rg_location          = "westeurope"
  webapp_appservice_plan_name = "osp_appservice_plan"
  webapp_name                 = "ospterraform2019"
  app_insights_name           = "ospterraform2019-appinsights"
  sql_rg_name                 = "OpenSpace2019TerraformSQL"
  sql_rg_location             = "westeurope"
  sql_server_admin            = "ospterraformadmin"
  sql_server_admin_pw         = "thisIsMySecret"
}

resource "azurerm_resource_group" "osp_rg" {
  name     = "${local.webapp_rg_name}"
  location = "${local.webapp_rg_location}"

  tags = {
    environment = "develop"
  }
}

resource "azurerm_app_service_plan" "osp_appservice_plan" {
  name                = "${local.webapp_appservice_plan_name}"
  location            = "${azurerm_resource_group.osp_rg.location}"
  resource_group_name = "${azurerm_resource_group.osp_rg.name}"

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_application_insights" "osp_webapp_appinsights" {
  name                = "${local.app_insights_name}"
  location            = "${azurerm_resource_group.osp_rg.location}"
  resource_group_name = "${azurerm_resource_group.osp_rg.name}"
  application_type    = "web"
}

resource "azurerm_app_service" "osp_webapp" {
  name                = "${local.webapp_name}"
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
  name     = "${local.sql_rg_name}"
  location = "${local.sql_rg_location}"
}

resource "azurerm_sql_server" "osp_sql_server" {
  name                = "${var.sql_server_name}"
  resource_group_name = "${azurerm_resource_group.osp_rg_sql.name}"
  location            = "${azurerm_resource_group.osp_rg_sql.location}"

  version                      = "12.0"
  administrator_login          = "${local.sql_server_admin}"
  administrator_login_password = "${local.sql_server_admin_pw}"

  lifecycle {
    ignore_changes = [
      #ignore changes to sql admin password
      administrator_login_password
    ]
  }
}

resource "azurerm_sql_database" "osp_sql_db" {
  name                = "${var.sql_db_name}"
  resource_group_name = "${azurerm_resource_group.osp_rg_sql.name}"
  location            = "${azurerm_resource_group.osp_rg_sql.location}"
  server_name         = "${azurerm_sql_server.osp_sql_server.name}"
}
