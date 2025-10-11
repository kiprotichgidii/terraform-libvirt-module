# Terraform provider for libvirt
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri ="qemu+ssh://root@192.168.1.100/system"
}

# Storage Pool Definition
resource "libvirt_pool" "storage_pool" {
  name = var.storage_pool_name
  type = "dir"
  target {
    path = var.storage_pool_path
  }
}

resource "libvirt_volume" "vm_disk" {
  count  = length(var.disks)
  name   = "${var.instance_name}-disk-${count.index}"
  pool   = libvirt_pool.storage_pool.name
  size   = var.disks[count.index].size
  format = var.disk_format
}

# Define network interfaces
resource "libvirt_network" "network_interface" {
  count = length(var.network_interfaces)
  name  = var.network_interfaces[count.index].name
  mode = "nat"
  
  # Define the network address range
  addresses = ["192.168.2.0/24"]  # Use an IP range that doesn’t conflict with the default libvirt network
}

# Define VM instances
resource "libvirt_domain" "vm" {
  count  = var.instance_count
  name   = "${var.instance_name}-${count.index}"
  memory = var.memory
  vcpu   = var.vcpu

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  # Attach bootable CD-ROM (ISO)
  disk {
    file   = var.cdrom_path # Path to the bootable ISO file
  }

  network_interface {
    network_name = libvirt_network.network_interface[count.index].name
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = "true"
    listen_address = "0.0.0.0"  
  }

  boot_device {
  dev = [ "cdrom", "hd", "network"]
}
  # Ensure the instance starts automatically
  autostart = true
}