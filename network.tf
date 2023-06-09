resource "azurerm_virtual_network" "target_vnet" {
  name                = "target_vnet"
  resource_group_name = azurerm_resource_group.target_rg.name
  location            = azurerm_resource_group.target_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "target_subnet" {
  name                 = "target_subnet"
  resource_group_name  = azurerm_resource_group.target_rg.name
  virtual_network_name = azurerm_virtual_network.target_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "target_nsg" {
  name                = "target_nsg"
  location            = azurerm_resource_group.target_rg.location
  resource_group_name = azurerm_resource_group.target_rg.name

  security_rule {
    name                       = "Inbound_Allow_All"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP_Access"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Outbound_Allow_All"
    priority                   = 1003
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "target_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.target_subnet.id
  network_security_group_id = azurerm_network_security_group.target_nsg.id
}

resource "azurerm_virtual_network" "attacker_vnet" {
  name                = "attacker_vnet"
  resource_group_name = azurerm_resource_group.attacker_rg.name
  location            = azurerm_resource_group.attacker_rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "attacker_subnet" {
  name                 = "attacker_subnet"
  resource_group_name  = azurerm_resource_group.attacker_rg.name
  virtual_network_name = azurerm_virtual_network.attacker_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "attacker_nsg" {
  name                = "attacker_nsg"
  location            = azurerm_resource_group.attacker_rg.location
  resource_group_name = azurerm_resource_group.attacker_rg.name

  security_rule {
    name                       = "WireGuard_Access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WG_SSH_Access"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.1.10.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "SSH_Access"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ReverseShell_Access"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8800-8899"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WG_HTTP_Access"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.1.10.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "HTTP_Access"
    priority                   = 1006
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WG_HTTPS_Access"
    priority                   = 1007
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.1.10.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "HTTPS_Access"
    priority                   = 1008
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WG_ICMP_Access"
    priority                   = 1009
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.10.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "ICMP_Access"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "WG_RDP_Access"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.1.10.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP_Access"
    priority                   = 1012
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Outbound_Allow_All"
    priority                   = 1011
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "attacker_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.attacker_subnet.id
  network_security_group_id = azurerm_network_security_group.attacker_nsg.id
}

resource "azurerm_virtual_network_peering" "attacker_to_target" {
  name                      = "attacker_to_target"
  resource_group_name       = azurerm_resource_group.target_rg.name
  virtual_network_name      = azurerm_virtual_network.target_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.attacker_vnet.id
}

resource "azurerm_virtual_network_peering" "target_to_attacker" {
  name                      = "target_to_attacker"
  resource_group_name       = azurerm_resource_group.attacker_rg.name
  virtual_network_name      = azurerm_virtual_network.attacker_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.target_vnet.id
}

resource "azurerm_subnet" "pivot_subnet" {
  name                 = "pivot_subnet"
  resource_group_name  = azurerm_resource_group.target_rg.name
  virtual_network_name = azurerm_virtual_network.target_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_route_table" "pivot_route_table" {
  name                = "pivot_route_table"
  location            = azurerm_resource_group.target_rg.location
  resource_group_name = azurerm_resource_group.target_rg.name

  route {
    name                   = "pivot_route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.nic_ms3_linux.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "pivot_subnet_route_table_association" {
  subnet_id      = azurerm_subnet.pivot_subnet.id
  route_table_id = azurerm_route_table.pivot_route_table.id
}
