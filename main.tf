# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }

  required_version = "~>1.1.7"
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

# Create storage account for MSR3
resource "azurerm_storage_account" "emea-cso-sa" {
  name                      = "case${var.caseNo}sa"
  resource_group_name       = azurerm_resource_group.emea-cso-rg.name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

### MANAGER INSTANCE ###

resource "azurerm_virtual_machine" "emea-cso-manager-vm" {
  depends_on = [azurerm_network_interface_security_group_association.emea-cso-allow-ssh]

  name                  = "${var.name}-case${var.caseNo}-managervm-${count.index}"
  count                 = var.manager_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-interface.*.id, count.index)]
  vm_size               = var.manager_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${ var.os_name == "UbuntuServer" ? "Canonical" : 
                    (var.os_name == "RHEL" ? "redhat" : 
                    (var.os_name == "0001-com-ubuntu-server-focal" ? "Canonical" : 
                    (var.os_name == "CentOS" ? "OpenLogic" : "here-should-be-suse" )))}"
    #publisher = "Canonical"
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
    computer_name  = "emea-cso-managervm-${count.index}"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#cloud-config
bootcmd:
 - >
   sudo systemctl stop firewalld && sudo systemctl disable firewalld
EOF
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
    public_ip_address_id          = element(azurerm_public_ip.emea-cso-worker-pub-ip.*.id, count.index)
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
  depends_on = [azurerm_network_interface_security_group_association.emea-cso-worker-allow-ssh]

  name                  = "${var.name}-case${var.caseNo}-workervm-${count.index}"
  count                 = var.worker_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-worker-interface.*.id, count.index)]
  vm_size               = var.worker_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    #publisher = "Canonical"
    publisher = "${ var.os_name == "UbuntuServer" ? "Canonical" : 
                    (var.os_name == "RHEL" ? "redhat" : 
                    (var.os_name == "0001-com-ubuntu-server-focal" ? "Canonical" : 
                    (var.os_name == "CentOS" ? "OpenLogic" : "here-should-be-suse" )))}"
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
    computer_name  = "emea-cso-workervm-${count.index}"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#cloud-config
bootcmd:
 - >
   sudo systemctl stop firewalld && sudo systemctl disable firewalld
EOF    
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
    public_ip_address_id          = element(azurerm_public_ip.emea-cso-msr-pub-ip.*.id, count.index)
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
    depends_on = [azurerm_network_interface_security_group_association.emea-cso-msr-allow-ssh]

  name                  = "${var.name}-case${var.caseNo}-msrvm-${count.index}"
  count                 = var.msr_count
  location              = var.location
  resource_group_name   = azurerm_resource_group.emea-cso-rg.name
  network_interface_ids = [element(azurerm_network_interface.emea-cso-msr-interface.*.id, count.index)]
  vm_size               = var.msr_instance_type

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${ var.os_name == "UbuntuServer" ? "Canonical" : 
                    (var.os_name == "RHEL" ? "redhat" : 
                    (var.os_name == "0001-com-ubuntu-server-focal" ? "Canonical" : 
                    (var.os_name == "CentOS" ? "OpenLogic" : "here-should-be-suse" )))}"
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
    computer_name  = "emea-cso-msrvm-${count.index}"
    admin_username = "azureuser"
    custom_data    = <<-EOF
#cloud-config
bootcmd:
 - >
   sudo systemctl stop firewalld && sudo systemctl disable firewalld
EOF
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
### WIN INSTANCE ###
########################

# resource azurerm_network_security_group "win_worker_nsg" {
#   name                = "${var.name}-case${var.caseNo}-win-worker-nsg"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.emea-cso-rg.name
# }

# resource "azurerm_network_security_rule" "win-worker-nsr" {
#   name                        = "Allow-All"
#   description                 = "Allow all for win-worker"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_address_prefix       = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.emea-cso-rg.name
#   network_security_group_name = azurerm_network_security_group.win_worker_nsg.name
# }

resource "azurerm_public_ip" "emea-cso-win-pub-ip" {
  name                = "${var.name}-case${var.caseNo}-win-instance-public-ip-${count.index}"
  count               = var.win_worker_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "emea-cso-win-interface" {
  name                = "${var.name}-case${var.caseNo}-msr-net-interface-${count.index}"
  count               = var.win_worker_count
  location            = var.location
  resource_group_name = azurerm_resource_group.emea-cso-rg.name

  ip_configuration {
    name                          = "emea-cso-ip-configuration"
    subnet_id                     = azurerm_subnet.emea-cso-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.emea-cso-win-pub-ip.*.id, count.index)
  }
}

resource "azurerm_network_interface_security_group_association" "emea-cso-win-allow-ssh" {
  count                     = length(azurerm_network_interface.emea-cso-win-interface)
  network_interface_id      = azurerm_network_interface.emea-cso-win-interface[count.index].id
  network_security_group_id = azurerm_network_security_group.emea-cso-sg.id
}

########################
########################
########################

#resource "azurerm_windows_virtual_machine" "emea-cso-win-vm" {
resource "azurerm_virtual_machine" "emea-cso-win-vm" {
    depends_on = [azurerm_network_interface_security_group_association.emea-cso-win-allow-ssh]

    name                  = "${var.name}-case${var.caseNo}-winvm-${count.index}"
    count                 = var.win_worker_count
    location              = var.location
    resource_group_name   = azurerm_resource_group.emea-cso-rg.name
    network_interface_ids = [element(azurerm_network_interface.emea-cso-win-interface.*.id, count.index)]
    vm_size               = "Standard_D4s_v3"

    storage_os_disk {
    name              = "emea-cso-win-osdisk-${count.index}"
    create_option     = "FromImage"
    caching           = "None"
    managed_disk_type = "Premium_LRS"
  }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-datacenter-gensecond"
        version   = "latest"
    }

  os_profile {
    # computer_name  = format("%s%03d", "win-worker-", (count.index + 1))
    computer_name  = "win-vm-${count.index}"
    admin_username = "azureuser"
    admin_password = random_string.mke_password.result
    custom_data    = <<EOF
# Set Administrator password
([adsi]("WinNT://./administrator, user")).SetPassword("${random_string.mke_password.result}")
# Snippet to enable WinRM over HTTPS with a self-signed certificate
# from https://gist.github.com/TechIsCool/d65017b8427cfa49d579a6d7b6e03c93
Write-Output "Disabling WinRM over HTTP..."
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Disable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"
Get-ChildItem WSMan:\Localhost\listener | Remove-Item -Recurse
Write-Output "Configuring WinRM for HTTPS..."
Set-Item -Path WSMan:\LocalHost\MaxTimeoutms -Value '1800000'
Set-Item -Path WSMan:\LocalHost\Shell\MaxMemoryPerShellMB -Value '1024'
Set-Item -Path WSMan:\LocalHost\Service\AllowUnencrypted -Value 'false'
Set-Item -Path WSMan:\LocalHost\Service\Auth\Basic -Value 'true'
Set-Item -Path WSMan:\LocalHost\Service\Auth\CredSSP -Value 'true'
New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Domain,Private
New-NetFirewallRule -Name "WINRM-HTTPS-In-TCP-PUBLIC" `
    -DisplayName "Windows Remote Management (HTTPS-In)" `
    -Description "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]" `
    -Group "Windows Remote Management" `
    -Program "System" `
    -Protocol TCP `
    -LocalPort "5986" `
    -Action Allow `
    -Profile Public
$Hostname = [System.Net.Dns]::GetHostByName((hostname)).HostName.ToUpper()
$pfx = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName $Hostname
$certThumbprint = $pfx.Thumbprint
$certSubjectName = $pfx.SubjectName.Name.TrimStart("CN = ").Trim()
New-Item -Path WSMan:\LocalHost\Listener -Address * -Transport HTTPS -Hostname $certSubjectName -CertificateThumbPrint $certThumbprint -Port "5986" -force
Write-Output "Restarting WinRM Service..."
Stop-Service WinRM
Set-Service WinRM -StartupType "Automatic"
Start-Service WinRM
EOF
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_virtual_machine_extension" "startup" {
  count                = var.win_worker_count
  name                 = format("%s%03d", "win-worker-", (count.index + 1))
  virtual_machine_id   = element(azurerm_virtual_machine.emea-cso-win-vm.*.id, count.index)
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/install.ps1; c:/azuredata/install.ps1\""
  }
SETTINGS
  }