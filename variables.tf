variable "location" {
  type        = string
  description = "This is where you have to mention region"
  default = "germanywestcentral"
}
variable "client_id" {
  type = string
  sensitive = true
}
variable "client_secret" {
  type = string
  sensitive = true
}
variable "name" {
  type        = string
  description = "Please Type your name so that You and Cloud admin can identify your resources."
}
variable "caseNo" {
  type        = string
  description = "This is the case number to track the issue."
  default = "0"
}
variable "os_name" {
  type        = string
  description = "Please type os name like the following, \nUbuntuServer\nredhat\ncentos\nsuse"
  default = "UbuntuServer"
}
variable "os_version" {
  type        = string
  description = "Please type os Version. For ubuntu 16.04-LTS,18,04-LTS etc. For redhat 7.8, 7.1, 8.1 etc"
  default = "18.04-LTS"
}
variable "worker_count" {
  type        = string
  description = "Please type the total number of worker"
  default = 0
}
variable "manager_count" {
  type        = string
  description = "Please type the total number of manager"
  default = 1
}
variable "msr_count" {
  type        = string
  description = "Please type the total number of dtr"
  default = 0
}
variable "msr_version_3" {
  type        = string
  description = "Please type 1 if you need MSRv3"
  default = 0
}
variable "win_worker_count" {
  type        = string
  description = "Please type the total number of Windows worker"
  default = 0
}
variable "msr_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "manager_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D2s_v3"
}
variable "win_worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "Standard_D4s_v3"
}
# variable "publicKey" {
#   type        = string
#   description = "If you are using a customized key, please paste your public key here."
# }
variable "image_repo" {
  type        = string
  default = "docker.io/mirantis"
}
variable "mcr_version" {
  type        = string
  description = "Please type your desired Mirantis Container Runtime version"
  default = "20.10.10"
}
variable "mke_version" {
  type        = string
  description = "Please type your desired Mirantis Kubernetes Engine version"
  default = "3.5.2"
}
variable "msr_version" {
  type        = string
  description = "Please type your desired Mirantis Secure Registry version"
}
variable "nfs_backend" {
  type        = string
  default = "0"
}

###
# AWS Section
###
variable "aws_region" {
  type        = string
  description = "This is where you have to mention region"
  default = "eu-central-1"
}
variable "aws_shared_credentials_file" {
  type = string
  default = "~/.aws/credentials"
}
variable "aws_profile" {
  type = string
  default = "PowerUserAccess-043802220583-SSO"
}
variable "aws_name" {
  type        = string
  description = "Please Type your name so that You and Cloud admin can identify your resources."
  default = "onovozhylov"
}
variable "aws_caseNo" {
  type        = string
  description = "This is the case number to track the issue."
}
variable "aws_os_name" {
  type        = string
  description = "Please type os name like the following, \nubuntu\nredhat\ncentos\nsuse"
  default = "ubuntu"
}
variable "aws_os_version" {
  type        = string
  description = "Please type os Version. For ubuntu 16.04,18,04 etc. For redhat 7.8, 7.1, 8.1 etc"
  default = "20.04"
}
variable "aws_worker_count" {
  type        = string
  description = "Please type the total number of worker"
  default = 0
}
variable "aws_manager_count" {
  type        = string
  description = "Please type the total number of manager"
  default = 1
}
variable "aws_msr_count" {
  type        = string
  description = "Please type the total number of dtr"
  default = 0
}
variable "aws_win_worker_count" {
  type        = string
  description = "Please type the total number of Windows worker"
  default = 0
}
variable "aws_msr_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "aws_worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "aws_manager_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "aws_win_worker_instance_type" {
  type        = string
  description = "Please type which Instance type you want. \n1. c4.xlarge : 4 vCPU - 4G MEM\n2. c4.2xlarge  : 8 vCPU - 15.7 G MEM\n3. m4.xlarge : 4 vCPU - 16 G MEM [ Best For Prod reproduce ]"
  default = "c4.xlarge"
}
variable "aws_publicKey" {
  type        = string
  description = "If you are using a customized key, please paste your public key here."
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQV6LLm3ib4kQyObYRVhWYwhCImpM+3ryZDL80E5me4XGMVUY45/b5KfYzyzLJpxVieEieBm7/+30I+ry4BIb0qJcYJV5gPdgty6PKUobluCrxH1rVLK8PgZTDuKcqCU9cfzmtaoHAp/7jCkrY8TbbcNwTZvAFANLEchwPesxxFR/UAYyWw0DTogGBdWJlR7dUhGWY4NK/feaxEgXgNm0ibPYg4+uly9MS3KjCMfhLxEUODxAniQ96Yc6p1wzllMolYP2Iq6aViCXw+jdQPKykGAMw6Po24SejaW8zaVGZh/UiI7pO9OiL0kTEvR+TBrzGx1UELnMn+pjV/ELhLRYjEW6VDXIITsv5mfEAejY/DEVmAxSlLJnn+7efImkHvK1DMySQx0ZW3SoNC6u7uKaGbHJmI8pxa16RTBUANOpAOUcQKd1JLhDN6CdV8JwhbbCUMzx/AqjR+vECyKuGhJnlt3yuKWffd+0tJ1Q5e2aA52c3pGy0mJd/PpEIcU5toqShF2511vpu37T+VnwsogZ8/Qj0gWdoy55Pme5+OqZ/pOiMxT4C9C6DkQnPs5Mb6z52b9FjbWuEUsCMy/YuRjvXtFGYUcbbdcqCjAqRjsuzSSKEgV64Le3szqN6iIMHPBt5KEdUKl5YdzNVhJPSbpg2ijYaxv5Hm7g3anXp82mI1w=="
}
variable "aws_image_repo" {
  type        = string
  default = "docker.io/mirantis"
}
variable "aws_mcr_version" {
  type        = string
  description = "Please type your desired Mirantis Container Runtime version"
  default = "20.10.7"
}
variable "aws_mke_version" {
  type        = string
  description = "Please type your desired Mirantis Kubernetes Engine version"
  default = "3.3.7"
}
variable "aws_msr_version" {
  type        = string
  description = "Please type your desired Mirantis Secure Registry version"
}
variable "aws_nfs_backend" {
  type        = string
  description = "Please type 1 or 0 for yes or no"
}