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
  addresses = var.network_mode != "bridge" ? [var.network_cidr] : null

  dynamic "dhcp" {
    for_each = var.network_mode == "bridge" && var.enable_dhcp ? [1] : []
    content {
      range_start = var.dhcp_range_start
      range_end   = var.dhcp_range_end
    }
  }
}

#----------------------------------------------------------
# Storage Pool Creation
#----------------------------------------------------------
resource "libvirt_pool" "storage_pool" {
  count     = var.create_storage_pool ? 1 : 0
  name      = var.storage_pool_name
  type      = var.storage_pool_type
  autostart = true
  target {
    path = var.storage_pool_path
  }
}

#----------------------------------------------------------
# Random Resource Creation
#----------------------------------------------------------
resource "random_password" "root_password" {
  count            = var.set_root_password ? 1 : 0
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_password" "user_password" {
  count            = var.set_user_password ? 1 : 0
  length           = 16
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
  content         = random_password.root_password.result
  filename        = "${path.cwd}/root_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "user_password" {
  count           = var.set_user_password ? 1 : 0
  content         = random_password.user_password.result
  filename        = "${path.cwd}/user_password.txt"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_private_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.cwd}/id_rsa.key"
  file_permission = "0600"
}

resource "local_sensitive_file" "ssh_public_key" {
  count           = var.generate_ssh_key ? 1 : 0
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "${path.cwd}/id_rsa.pub"
  file_permission = "0644"
}

#----------------------------------------------------------
# Create a libvirt volume for the base image
#----------------------------------------------------------
resource "libvirt_volume" "base_image" {
  count  = module.cloud_images.os.available ? 1 : 0
  name   = "${var.vm_name}-base.qcow2"
  pool   = var.storage_pool
  source = module.cloud_images.os.url
  format = "qcow2"
}

#----------------------------------------------------------
# Create a copy-on-write volume for the VM
#----------------------------------------------------------
resource "libvirt_volume" "vm_disk" {
  count            = var.vm_count
  name             = "${var.vm_name}.qcow2"
  base_volume_id   = libvirt_volume.base_image.id
  base_volume_name = libvirt_volume.base_image.name
  pool             = var.storage_pool
  format           = "qcow2"
  size             = 1024 * 1024 * 1024 * var.disk_size
}

#----------------------------------------------------------
# Generate Cloud-Init ISO
#----------------------------------------------------------
data "template_file" "user_data" {
  template = file("${path.root}/templates/cloud-init/user_data.tpl")

  vars = {
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
    packages                 = join(" ", var.packages)
    runcmds                  = join(" ", var.runcmds)
  }
}

data "template_file" "network_config" {
  template = file("${path.root}/templates/cloud-init/network_config.tpl")

  vars = {
    ip_address  = var.ip_address
    gateway     = var.ip_gateway
    nic         = var.network_interface
    enable_dhcp = var.enable_dhcp
    dns         = join(" ", var.dns_servers)
  }
}

data "template_file" "meta_data" {
  template = file("${path.root}/templates/cloud-init/meta_data.tpl")

  vars = {
    instance_id    = var.vm_name
    local_hostname = var.vm_name
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "${var.vm_name}-cloudinit.iso"
  pool           = var.storage_pool
  user_data      = data.template_file.user_data.rendered
  meta_data      = data.template_file.meta_data.rendered
  network_config = data.template_file.network_config.rendered
}

#----------------------------------------------------------
# Create the Virtual Machine
#----------------------------------------------------------
resource "libvirt_domain" "vm_domain" {
  count      = var.vm_count
  name       = var.vm_name
  memory     = var.memory
  cpu_mode   = var.cpu_mode
  vcpu       = var.vcpu
  austostart = var.autostart_vm
  qemu_agent = true
  cloudinit  = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
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
    volume_id = libvirt_volume.vm_disk.id
  }

  depends_on = [libvirt_cloudinit_disk.commoninit]
}