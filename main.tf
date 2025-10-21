# Libvirt Provider URI
terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@192.168.1.100/system"
}

module "libvirt_vm" {
  source = "./modules/libvirt-vm"

  # Network parameters
  create_network    = true
  network_name      = "default_01"
  network_mode      = "nat"
  autostart_network = true
  network_cidr      = ["172.20.0.0/24"]

  # Storage Pool parameters
  create_storage_pool = true
  storage_pool_name   = "default_pool"
  storage_pool_type   = "dir"
  storage_pool_path   = "/var/lib/libvirt/images/"

  # VM parameters
  os_name    = "ubuntu"
  os_version = "24.04"
  vm_name   = "Ubuntu"
  vm_count  = 1
  memory    = 2048
  vcpu      = 2
  disk_size = 20
  timezone = "Africa/Nairobi"
}

output "ssh_username" {
  value = module.libvirt_vm.ssh_user_name
}

output "vm_ip_addresses" {
  value = module.libvirt_vm.vm_ip_addresses
}

output "ssh_commands" {
  value = module.libvirt_vm.ssh_commands
}
