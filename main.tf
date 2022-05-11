provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = "d8cf16d8-db67-4e89-bcbe-d6316fce6378"
  tenant_id       = "6d498697-2abe-46df-ae3e-4e5b2e25f280"
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# This feature is intended to avoid the unintentional destruction of nested Resources provisioned through some
# │ other means (for example, an ARM Template Deployment) - as such you must either remove these Resources, or
# │ disable this behaviour using the feature flag `prevent_deletion_if_contains_resources` within the `features`
# │ block when configuring the Provider, for example:
# │ 
# │ provider "azurerm" {
# │   features {
# │     resource_group {
# │       prevent_deletion_if_contains_resources = false
# │     }
# │   }
# │ }
# │ 
# │ When that feature flag is set, Terraform will skip checking for any Resources within the Resource Group and
# │ delete this using the Azure API directly (which will clear up any nested resources).
# │ 
# │ More information on the `features` block can be found in the documentation:
# │ https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#features

module "common" {
  source   = "./modules/common"
  location = var.location
  name     = var.name
  caseNo   = var.caseNo
  rg       = module.vnet.rg
  # vnet_id      = module.vnet.id
  # subnet_id    = module.vnet.subnet_id
  # tags         = var.tags
}

module "vnet" {
  source   = "./modules/vnet"
  location = var.location
  name     = var.name
  caseNo   = var.caseNo
  # host_cidr            = var.vnet_cidr
  # subnet_cidr          = var.address_space
  # virtual_network_name = var.vnet_name
  # tags                 = var.tags
}

module "manager" {
  source                = "./modules/manager"
  caseNo                = var.caseNo
  manager_count         = var.manager_count
  name                  = var.name
  location              = var.location
  manager_instance_type = var.manager_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
  #vnet_id             = module.vnet.id
  #tags                = var.tags
  #fault_domain_count  = var.fault_domain_count
  #update_domain_count = var.update_domain_count
  #subnet_id           = module.vnet.subnet_id
  #ssh_key             = module.common.ssh_key
  #image               = var.image_ubuntu1804
}

module "worker" {
  source                = "./modules/worker"
  caseNo                = var.caseNo
  worker_count          = var.worker_count
  name                  = var.name
  location              = var.location
  worker_instance_type  = var.worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "msr-worker" {
  source                = "./modules/msr-worker"
  caseNo                = var.caseNo
  msr_count             = var.msr_count
  name                  = var.name
  location              = var.location
  msr_instance_type     = var.msr_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "win-worker" {
  source                = "./modules/win-worker"
  caseNo                = var.caseNo
  win_worker_count      = var.win_worker_count
  name                  = var.name
  location              = var.location
  win_worker_instance_type     = var.win_worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  # testing separate subnet
  #subnet_win_id         = module.vnet.subnet_win_id
  security_group_id     = module.vnet.security_group_id
  password          = module.common.password
}