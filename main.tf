# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }

  required_version = "1.1.7"
}

provider "azurerm" {
  features {}

  subscription_id = "d8cf16d8-db67-4e89-bcbe-d6316fce6378"
  tenant_id       = "6d498697-2abe-46df-ae3e-4e5b2e25f280"
  client_id       = var.client_id
  client_secret   = var.client_secret
}

resource "azurerm_resource_group" "emea-cso-rg" {
  name     = "${var.name}-case${var.caseNo}-rg"
  location = var.location
}

# Creating two random password for MKE username and Password
resource "random_pet" "mke_username" {
  length  = 2
}
resource "random_string" "mke_password" {
  length  = 20
  special = false
}

### NETWORK SECTION ###
# Create a virtual network
resource "azurerm_virtual_network" "emea-cso-net" {
  name                = "${var.name}-case${var.caseNo}-net"
  address_space       = ["172.16.0.0/12"]
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name
}

resource "azurerm_subnet" "emea-cso-subnet" {
  name                 = "${var.name}-case${var.caseNo}-subnet"
  resource_group_name  = azurerm_resource_group.emea-cso-rg.name
  virtual_network_name = azurerm_virtual_network.emea-cso-net.name
  address_prefixes     = ["172.16.1.0/24"]
}

resource "azurerm_network_security_group" "emea-cso-sg" {
  name                = "${var.name}-case${var.caseNo}-sg"
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name

  security_rule {
    name                       = "allowAll"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "emea-cso-pub-ip" {
  name                = "${var.name}-case${var.caseNo}-instance-public-ip-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "emea-cso-interface" {
  name                = "${var.name}-case${var.caseNo}-net-interface-${count.index}"
  count               = var.manager_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name

  ip_configuration {
    name                          = "emea-cso-ip-configuration"
    subnet_id                     = azurerm_subnet.emea-cso-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.emea-cso-pub-ip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "emea-cso-allow-ssh" {
  count                     = length(azurerm_network_interface.emea-cso-interface)
  network_interface_id      = azurerm_network_interface.emea-cso-interface[count.index].id
  network_security_group_id = azurerm_network_security_group.emea-cso-sg.id
}

### MANAGER INSTANCE ###

resource "azurerm_virtual_machine" "emea-cso-manager-vm" {
  name                  = "${var.name}-case${var.caseNo}-managerVM-${count.index}"
  count                 = var.manager_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-interface.*.id, count.index)]
  vm_size               = var.manager_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.os_name
    sku       = var.os_version
    version   = "latest"
  }
  storage_os_disk {
    name              = "emea-cso-manager-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "emea-cso-managerVM-${count.index}"
    admin_username = "azureuser"
    #admin_password = "..."
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("id_rsa.pub")
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }
}

########################
### WORKER INSTANCE ###
########################

resource "azurerm_public_ip" "emea-cso-worker-pub-ip" {
  name                = "${var.name}-case${var.caseNo}-worker-instance-public-ip-${count.index}"
  count               = var.worker_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "emea-cso-worker-interface" {
  name                = "${var.name}-case${var.caseNo}-worker-net-interface-${count.index}"
  count               = var.worker_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name

  ip_configuration {
    name                          = "emea-cso-ip-configuration"
    subnet_id                     = azurerm_subnet.emea-cso-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.emea-cso-worker-pub-ip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "emea-cso-worker-allow-ssh" {
  count                     = length(azurerm_network_interface.emea-cso-worker-interface)
  network_interface_id      = azurerm_network_interface.emea-cso-worker-interface[count.index].id
  network_security_group_id = azurerm_network_security_group.emea-cso-sg.id
}

########################
########################
########################

resource "azurerm_virtual_machine" "emea-cso-worker-vm" {
  name                  = "${var.name}-case${var.caseNo}-workerVM-${count.index}"
  count                 = var.worker_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-worker-interface.*.id, count.index)]
  vm_size               = var.worker_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.os_name
    sku       = var.os_version
    version   = "latest"
  }
  storage_os_disk {
    name              = "emea-cso-worker-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "emea-cso-workerVM-${count.index}"
    admin_username = "azureuser"    
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("id_rsa.pub")
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }
}

########################
### MSR INSTANCE ###
########################

resource "azurerm_public_ip" "emea-cso-msr-pub-ip" {
  name                = "${var.name}-case${var.caseNo}-msr-instance-public-ip-${count.index}"
  count               = var.msr_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "emea-cso-msr-interface" {
  name                = "${var.name}-case${var.caseNo}-msr-net-interface-${count.index}"
  count               = var.msr_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name

  ip_configuration {
    name                          = "emea-cso-ip-configuration"
    subnet_id                     = azurerm_subnet.emea-cso-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = element(azurerm_public_ip.emea-cso-msr-pub-ip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "emea-cso-msr-allow-ssh" {
  count                     = length(azurerm_network_interface.emea-cso-msr-interface)
  network_interface_id      = azurerm_network_interface.emea-cso-msr-interface[count.index].id
  network_security_group_id = azurerm_network_security_group.emea-cso-sg.id
}

########################
########################
########################

resource "azurerm_virtual_machine" "emea-cso-msr-vm" {
  name                  = "${var.name}-case${var.caseNo}-msrVM-${count.index}"
  count                 = var.msr_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-msr-interface.*.id, count.index)]
  vm_size               = var.msr_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.os_name
    sku       = var.os_version
    version   = "latest"
  }
  storage_os_disk {
    name              = "emea-cso-msr-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "emea-cso-msrVM-${count.index}"
    admin_username = "azureuser"
    #admin_password = "..."
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("id_rsa.pub")
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }
}