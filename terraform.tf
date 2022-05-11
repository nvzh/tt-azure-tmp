terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.5.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.2"
    }
  }

  required_version = "1.1.9"
}

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