# ----------------------------------------------------------
# Cloud Images module reference
#----------------------------------------------------------
module "cloud_images" {
  source     = "../cloud-images"
  os_name    = var.os_name
  os_version = var.os_version
}

#----------------------------------------------------------
# Libvirt Network Creation
#----------------------------------------------------------
resource "libvirt_network" "vm_network" {
  count     = var.create_network ? 1 : 0
  name      = var.network_name
  mode      = var.network_mode
  autostart = var.autostart_network
  mtu       = var.network_mode != "bridge" ? var.network_mtu : null
  addresses = var.network_mode != "bridge" ? var.network_cidr : null

  dynamic "dhcp" {
    for_each = var.network_mode == "nat" ? [1] : []
    content {
      enabled = var.enable_dhcp
    }
  }
}

#----------------------------------------------------------
# Storage Pool Creation
#----------------------------------------------------------
resource "libvirt_pool" "storage_pool" {
  count = var.create_storage_pool ? 1 : 0
  name  = var.storage_pool_name
  type  = var.storage_pool_type

  target {
    path = var.storage_pool_path
  }
}

#----------------------------------------------------------
# Random Resource Creation
#----------------------------------------------------------
resource "random_password" "root_password" {
  count            = var.set_root_password ? 1 : 0
  length           = 8
  special          = true
  override_special = "_%@"
}

resource "random_password" "user_password" {
  count            = var.set_user_password ? 1 : 0
  length           = 8
  special          = true
  override_special = "_%@"
}

resource "tls_private_key" "ssh_key" {
  count     = var.generate_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#----------------------------------------------------------
# Files Creation 
#----------------------------------------------------------
resource "local_sensitive_file" "root_password" {
  count           = var.set_root_password ? 1 : 0
  content         = random_password.root_password[count.index].result
  filename        = "${path.cwd}/root_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "user_password" {
  count           = var.set_user_password ? 1 : 0
  content         = random_password.user_password[count.index].result
  filename        = "${path.cwd}/user_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_private_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.ssh_key[count.index].private_key_pem
  filename        = "${path.cwd}/id_rsa.key"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_public_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.ssh_key[count.index].public_key_openssh
  filename        = "${path.cwd}/id_rsa.pub"
  file_permission = "0644"
}

#----------------------------------------------------------
# Create a libvirt volume for the base image
#----------------------------------------------------------
resource "libvirt_volume" "base_image" {
  count  = var.local_image_path != "" || module.cloud_images.available ? 1 : 0
  name   = "${var.vm_name}-base.qcow2"
  pool   = var.create_storage_pool ? libvirt_pool.storage_pool[0].name : var.storage_pool_name
  source = var.local_image_path != "" ? var.local_image_path : module.cloud_images.url
  format = "qcow2"
}

#----------------------------------------------------------
# Create a copy-on-write volume for the VM
#----------------------------------------------------------
resource "libvirt_volume" "vm_disk" {
  count          = var.vm_count
  name           = "${var.vm_name}.qcow2"
  base_volume_id = libvirt_volume.base_image[count.index].id
  #base_volume_name = libvirt_volume.base_image[count.index].name
  pool   = var.create_storage_pool ? libvirt_pool.storage_pool[0].name : var.storage_pool_name
  format = "qcow2"
  size   = 1024 * 1024 * 1024 * var.disk_size
}

#----------------------------------------------------------
# Generate Cloud-Init ISO
#----------------------------------------------------------
data "template_cloudinit_config" "cloudinit" {
  count         = var.vm_count
  gzip          = false
  base64_encode = false

  part {
    filename     = "user-data"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init/user_data.tpl", {

      timezone                 = var.timezone
      manage_etc_hosts         = var.manage_etc_hosts
      preserve_hostname        = var.preserve_hostname
      enable_ssh_password_auth = var.enable_ssh_password_auth
      disable_ssh_root_login   = var.disable_ssh_root_login
      lock_root_user_password  = var.lock_root_user_password
      set_root_password        = var.set_root_password
      root_password            = local.root_password_hash
      user_name                = var.user_name
      user_fullname            = var.ssh_user_fullname
      user_shell               = var.ssh_user_shell
      user_password            = local.user_password_hash
      set_user_password        = var.set_user_password
      lock_user_password       = var.lock_user_password
      authorized_keys          = local.combined_ssh_keys
      disable_ipv6             = var.disable_ipv6
      package_update           = var.package_update
      package_upgrade          = var.package_upgrade
      packages                 = var.packages
      runcmds                  = var.runcmds
    })
  }

  part {
    filename     = "meta-data"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init/meta_data.tpl", {

      instance_id = var.vm_name
      hostname    = var.hostname != "" ? var.hostname : var.vm_name
    })
  }

  part {
    filename     = "network-config"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init/network_config.tpl", {

      ip_address  = var.ip_address
      gateway     = var.ip_gateway
      nic         = var.network_interface
      enable_dhcp = var.enable_dhcp
      dns_servers = var.dns_servers
    })
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.vm_count
  name           = "${var.vm_name}-cloudinit.iso"
  pool           = var.create_storage_pool ? libvirt_pool.storage_pool[0].name : var.storage_pool_name
  user_data      = data.template_cloudinit_config.cloudinit[count.index].rendered
  meta_data      = data.template_cloudinit_config.cloudinit[count.index].part[1].content
  network_config = data.template_cloudinit_config.cloudinit[count.index].part[2].content
}

#----------------------------------------------------------
# Create the Virtual Machine
#----------------------------------------------------------
resource "libvirt_domain" "vm_domain" {
  count  = var.vm_count
  name   = var.vm_name
  memory = var.memory
  cpu {
    mode = var.cpu_mode
  }
  vcpu       = var.vcpu
  autostart  = var.autostart_vm
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_name   = var.create_network ? libvirt_network.vm_network[0].name : var.network_name
    wait_for_lease = true
  }

  graphics {
    type           = "vnc"
    listen_type    = "address"
    listen_address = var.graphics_listen_address
    autoport       = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  depends_on = [libvirt_cloudinit_disk.commoninit]
}