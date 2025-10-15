# ----------------------------------------------------------
# Terraform and Provider Configuration
#----------------------------------------------------------
terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}