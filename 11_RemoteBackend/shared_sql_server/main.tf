provider "azurerm" {
  version = ">=1.34.0"
}

variable "sql_server_name" {
  type = string
}

locals {
  sql_rg_name         = "OpenSpace2019TerraformSQL"
  sql_rg_location     = "westeurope"
  sql_server_admin    = "ospterraformadmin"
  sql_server_admin_pw = "thisIsMySecret"
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

#terraform import azurerm_resource_group.osp_rg_sql /subscriptions/<YOURSUBID>/resourceGroups/OpenSpace2019TerraformSQL
#terraform import azurerm_sql_server.osp_sql_server /subscriptions/<YOURSUBID>/resourceGroups/OpenSpace2019TerraformSQL/providers/Microsoft.Sql/servers/ospterraformsqlserver
