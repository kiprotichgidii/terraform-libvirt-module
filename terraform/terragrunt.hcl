terraform {
  source = "./modules/libvirt-vm"
}

inputs = {
  instance_name       = "example-vm"
  instance_count      = 2
  memory              = 2048
  vcpu                = 2
  disks               = [{ size = 10 }, { size = 20 }]
  storage_pool_name   = "images"
  storage_pool_path   = "/var/lib/libvirt/images"
  image_path         = "/var/lib/libvirt/images/al2023-kvm-2023.6.20241010.0-kernel-6.1-x86_64.xfs.gpt.qcow2"
  disk_format        = "qcow2"
  network_interfaces  = [{ name = "default" }]
}
