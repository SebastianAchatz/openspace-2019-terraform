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
  sql_rg_name         = "OpenSpace2019TerraformSQL"
  sql_rg_location     = "westeurope"
  sql_server_admin    = "ospterraformadmin"
  sql_server_admin_pw = "thisIsMySecret"
}

data "azurerm_resource_group" "osp_rg_sql" {
  name = "${local.sql_rg_name}"
}

data "azurerm_sql_server" "osp_sql_server" {
  name                = "${var.sql_server_name}"
  resource_group_name = "${local.sql_rg_name}"
}
#terraform state rm module.webapp_sql_persistence.azurerm_resource_group.osp_rg_sql
#terraform state rm module.webapp_sql_persistence.azurerm_sql_server.osp_sql_server

resource "azurerm_sql_database" "osp_sql_db" {
  name                = "${var.sql_db_name}"
  resource_group_name = "${data.azurerm_resource_group.osp_rg_sql.name}"
  location            = "${data.azurerm_resource_group.osp_rg_sql.location}"
  server_name         = "${data.azurerm_sql_server.osp_sql_server.name}"
}
