provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "target_rg" {
  name     = var.target_resource_group_name
  location = "East US"
}

resource "azurerm_resource_group" "attacker_rg" {
  name     = var.attacker_resource_group_name
  location = "West US"
}

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.target_rg.name
  location                 = azurerm_resource_group.target_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = false
}

resource "azurerm_storage_container" "sc" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "blob"
}

resource "null_resource" "upload_provisioners" {
  depends_on = [azurerm_storage_container.sc]

  provisioner "local-exec" {
    command = "./upload_provisioners.sh \"${var.storage_account_name}\" \"${var.storage_container_name}\""
  }
}

resource "null_resource" "generate_wireguard_keys"{ 
  provisioner "local-exec" {
    command = <<EOF
      umask 077
      wg genkey > kaliprivatekey
      wg pubkey < kaliprivatekey > kalipublickey
EOF
  }  
}

data "local_file" "kali_private_key" {
  depends_on = [null_resource.generate_wireguard_keys]
  filename   = "kaliprivatekey"
}

data "local_file" "kali_public_key" {
  depends_on = [null_resource.generate_wireguard_keys]
  filename   = "kalipublickey"
}

data "local_file" "client_public_key" {
  filename = "publickey"
}

resource "null_resource" "ms3_linux_packer" {
  depends_on = [azurerm_resource_group.target_rg]

  provisioner "local-exec" {
    command = "packer build ms3-linux.pkr.hcl"
  }
}

