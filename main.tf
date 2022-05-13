module "common" {
  source   = "./modules/azure/common"
  location = var.location
  name     = var.name
  caseNo   = var.caseNo
  rg       = module.vnet.rg
}

module "vnet" {
  source   = "./modules/azure/vnet"
  location = var.location
  name     = var.name
  caseNo   = var.caseNo
}

module "manager" {
  source                = "./modules/azure/manager"
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
}

module "worker" {
  source                = "./modules/azure/worker"
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
  source                = "./modules/azure/msr-worker"
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
  source                = "./modules/azure/win-worker"
  caseNo                = var.caseNo
  win_worker_count      = var.win_worker_count
  name                  = var.name
  location              = var.location
  win_worker_instance_type     = var.win_worker_instance_type
  os_name               = var.os_name
  os_version            = var.os_version
  rg                    = module.vnet.rg
  subnet_id             = module.vnet.subnet_id
  security_group_id     = module.vnet.security_group_id
  password          = module.common.password
}

###
# AWS Section
###
# module "aws" {
#   source                = "./modules/aws"
#   aws_region                        = var.aws_region
#   aws_profile                   = var.aws_profile
#   aws_shared_credentials_file   = var.aws_shared_credentials_file
#   aws_name                          = var.aws_name
#   aws_caseNo                        = var.aws_caseNo
#   aws_os_name                       = var.aws_os_name
#   aws_os_version                    = var.aws_os_version
#   aws_manager_count                 = var.aws_manager_count
#   aws_manager_instance_type         = var.aws_manager_instance_type
#   aws_msr_count                     = var.aws_msr_count
#   aws_msr_instance_type             = var.aws_msr_instance_type
#   aws_nfs_backend                   = var.aws_nfs_backend
#   aws_worker_count                  = var.aws_worker_count
#   aws_worker_instance_type          = var.aws_worker_instance_type
#   aws_win_worker_count              = var.aws_win_worker_count
#   aws_win_worker_instance_type      = var.aws_win_worker_instance_type
#   aws_mcr_version                   = var.aws_mcr_version
#   aws_mke_version                   = var.aws_mke_version
#   aws_msr_version                   = var.aws_msr_version
#   aws_image_repo                    = var.aws_image_repo
#   aws_publicKey                     = var.aws_publicKey
# }