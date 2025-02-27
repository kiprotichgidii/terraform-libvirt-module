module "libvirt_vms" {
  source            = "./modules/libvirt-vm"
  instance_name     = "Ubuntu-24.04"
  instance_count    = 1
  memory            = 4096
  vcpu              = 3
  storage_pool_name = "terraform"
  storage_pool_path = "/var/lib/libvirt/kvm"
  cdrom_path        = "/var/lib/libvirt/virtual-machines/ubuntu-24.04.1-live-server-amd64.iso"

  disks = [
    { size = 20971520000 },
    { size = 10485760000 }
  ]

  network_interfaces = [{ name = "terraform" }]
}

# Output the instance details
output "vm_names" {
  value = module.libvirt_vms.instance_names
}

#output "vm_ips" {
#  value = module.libvirt_vms.instance_ips
#}