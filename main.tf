provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.name}-example-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "example" {
  name                = "${var.name}-example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.name}-internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Without the use of variables
module "linux_vm_set" {
  source              = "git::https://github.com/jasonskidmore/terraform-azure-linux-scale-set.git"
  instance_count      = 1
  name                = "${var.name}-linux-vm-set"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface   = {name = "demo", subnet_id = azurerm_subnet.internal.id}
  tags                = {costcenter = "777747", client = "demo"}
}