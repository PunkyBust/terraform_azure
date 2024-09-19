resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = var.vnet_address_space
  location            = var.location_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "interface-nic"
  location            = var.location_name
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "acceptanceTestSecurityGroupye"
  location            = var.location_name
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "APP-TRAFFIC"
    priority                   = 101
    access                     = "Allow"
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "Link-NSG-to-NIC" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "lb-public-ip" {
  name                = "loadbalancer-public-ip"
  location            = var.location_name
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  # allocation_method   = "Static"
  # domain_name_label   = var.domain_name_label
}

resource "azurerm_lb" "loadbalancer" {
  name                = "loadbalancer"
  location            = var.location_name
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb-public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend-pool" {
  loadbalancer_id = azurerm_lb.loadbalancer.id
  name            = "IP_Backend_Pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "backend-interface" {
  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend-pool.id
}

resource "azurerm_lb_rule" "lb-rule" {
  loadbalancer_id                = azurerm_lb.loadbalancer.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 5000 
  backend_port                   = 5000
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids      = [azurerm_lb_backend_address_pool.backend-pool.id]

}

output "public_ip_loadbalancer" {
  value = azurerm_public_ip.lb-public-ip.id
  description = "The private IP address of the newly created Azure VM"
}