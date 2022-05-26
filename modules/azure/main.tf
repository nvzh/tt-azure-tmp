terraform {
  backend "local" {
    path = "/terraTrain/terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
  }

  required_version = "~> 1.1.6"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

module "common" {
  source   = "./common"
  location = var.region
  name     = var.name
  caseNu   = var.caseNu
  rg       = module.vnet.rg
}

module "vnet" {
  source   = "./vnet"
  location = var.region
  name     = var.name
  caseNu   = var.caseNu
}

module "manager" {
  source                = "./manager"
  caseNu                = var.caseNu
  manager_count         = var.manager_count
  name                  = var.name
  location              = var.region
  manager_instance_type = var.manager_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "worker" {
  source                = "./worker"
  caseNu                = var.caseNu
  worker_count          = var.worker_count
  name                  = var.name
  location              = var.region
  worker_instance_type  = var.worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "msr-worker" {
  source                = "./msr-worker"
  caseNu                = var.caseNu
  msr_count             = var.msr_count
  name                  = var.name
  location              = var.region
  msr_instance_type     = var.msr_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}

module "win-worker" {
  source                = "./win-worker"
  caseNu                = var.caseNu
  win_worker_count      = var.win_worker_count
  name                  = var.name
  location              = var.region
  win_worker_instance_type     = var.win_worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
  password          = module.common.password
}

module "nfs-node" {
  source                = "./nfs-node"
  caseNu                = var.caseNu
  nfs_backend           = var.nfs_backend
  name                  = var.name
  location              = var.region
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
}