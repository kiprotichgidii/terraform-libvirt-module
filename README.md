# Terraform Libvirt Module

A comprehensive Terraform module for provisioning Virtual Machines on KVM/Libvirt. This module abstracts the complexity of `dmacvicar/libvirt` provider, offering a simplified interface for VM creation, network management, storage pooling, and Cloud-Init configuration.

## 🚀 Features

- **VM Provisioning**: Create one or multiple VMs from Cloud images or local generic Cloud-Init images.
- **Network Management**:
  - Auto-create Libvirt networks (NAT, Bridge, or Routed).
  - DHCP configuration.
  - DNS forwarding tables.
- **Storage Management**:
  - Auto-create Storage Pools.
  - Support for multiple backing stores.
- **Cloud-Init Configuration**:
  - Automatic user creation and SSH key injection.
  - Network configuration (Static IP or DHCP).
  - Package installation and upgrades.
  - Arbitrary commands execution (`runcmds`).
- **Security**:
  - Secret generation (Root/User passwords) saved to local files.
  - SSH Private Key generation (saved locally).
  - Option to disable Root SSH login.

## 📋 Requirements

| Name | Version |
|------|---------|
| **Terraform** | `>= 1.0` |
| **Libvirt Provider** | `dmacvicar/libvirt` (0.8.3) |
| **Libvirt Daemon** | on target host |

## 🛠 Usage

### Example Usage with Network and Storage Pool Creation

```hcl
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
  uri = "qemu+ssh://root@192.168.1.20/system?sshauth=privkey&keyfile=~/.ssh/id_ecdsa"
  #uri = "qemu+ssh://root@192.168.1.20/system?sshauth=privkey&keyfile=~/.ssh/id_ecdsa&no_verify=1"
  #uri = "qemu:///system"
}

module "libvirt_vm" {
  source = "./modules/libvirt-vm"
  # source = "git::https://github.com/kiprotichgidii/terraform-libvirt-module.git//modules/libvirt-vm?ref=main"

  # Network parameters
  create_network    = true
  network_name      = "opentofu-net"
  network_mode      = "nat"
  autostart_network = true
  network_cidr      = ["172.20.0.0/24"]

  # Storage Pool parameters
  create_storage_pool = true
  storage_pool_name   = "opentofu-pool"
  storage_pool_type   = "dir"
  storage_pool_path   = "/var/lib/libvirt/images/"

  # VM parameters
  local_image_path        = "/var/lib/libvirt/cloud-images/ubuntu-24.04-server-cloudimg-amd64.img" # No local image, use cloud image
  os_name                 = "ubuntu"
  os_version              = "24.04"
  vm_name                 = "Ubuntu"
  hostname                = "ubuntu-noble"
  vm_count                = 1
  memory                  = 2048
  vcpu                    = 2
  disk_size               = 20
  graphics_listen_address = "0.0.0.0"
  timezone                = "Africa/Nairobi"
}

output "network_name" {
  value = module.libvirt_vm.network_name
}

output "storage_pool_name" {
  value = module.libvirt_vm.pool_name
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

```

## ⚙️ Configuration Reference

### Provider & Images
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `livirt_uri` | `string` | `"qemu:///system"` | Connection URI for Libvirt. |
| `os_name` | `string` | `"ubuntu"` | Operating System name (e.g., ubuntu, centos-stream). |
| `os_version` | `string` | `"latest"` | OS version (e.g., latest, 24.04). |
| `local_image_path` | `string` | `""` | Path to local qcow2 image. Overrides `os_name`. |

### Virtual Machine Resources
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `vm_name` | `string` | `"Ubuntu"` | Base name for the VM instance(s). |
| `hostname` | `string` | `""` | Custom hostname (defaults to `vm_name`). |
| `vm_count` | `number` | `1` | Number of VM instances to create. |
| `memory` | `number` | `4096` | Memory size in MB. |
| `vcpu` | `number` | `2` | Number of virtual CPUs. |
| `cpu_mode` | `string` | `"host-passthrough"` | CPU emulation mode. |
| `disk_size` | `number` | `20` | Root disk size in GB. |
| `autostart_vm` | `bool` | `true` | Start VM automatically on host boot. |
| `graphics_listen_address` | `string` | `"127.0.0.1"` | VNC listen address (0.0.0.0 for public). |
| `timezone` | `string` | `"UTC"` | System timezone setting. |

### Network Configuration
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_network` | `bool` | `false` | whether to create a new Libvirt network. |
| `network_name` | `string` | `"default"` | Name of the network to create or attach to. |
| `network_mode` | `string` | `"nat"` | Network mode (`nat`, `bridge`, `routed`). |
| `network_cidr` | `list(string)` | `["172.20.0.0/24"]` | Network CIDR (for nat/routed). |
| `network_mtu` | `number` | `1500` | Network MTU size. |
| `autostart_network` | `bool` | `true` | Start network on host boot. |
| `enable_dhcp` | `bool` | `true` | Enable DHCP server on the network. |
| `disable_ipv6` | `bool` | `false` | Disable IPv6 networking in the VM. |
| `ip_address` | `string` | `"172.20.0.10/24"` | Static IP CIDR. Disables DHCP for standard config. |
| `ip_gateway` | `string` | `"172.20.0.1"` | Gateway IP for static configuration. |
| `dns_servers` | `list(string)` | `["8.8.8.8"]` | List of DNS servers. |
| `network_interface` | `string` | `"ens3"` | Interface name inside the VM (for Cloud-Init networking). |
| `vm_domain` | `string` | `"home.local"` | Domain name used in network configuration. |

### Storage Pools
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `create_storage_pool` | `bool` | `false` | Whether to create a new storage pool. |
| `storage_pool_name` | `string` | `"default_pool"` | Name of the storage pool. |
| `storage_pool_type` | `string` | `"dir"` | Pool type (`dir`, `logical`, `zfs`, etc.). |
| `storage_pool_path` | `string` | `"/var/lib/..."` | Path on host for the storage pool. |

### Cloud-init Variables

#### User & Security
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `user_name` | `string` | `"cloud-user"` | Default username to create. |
| `ssh_user_fullname` | `string` | `"Cloud User"` | Full name (GECOS). |
| `ssh_user_shell` | `string` | `"/bin/bash"` | User login shell. |
| `generate_ssh_key` | `bool` | `true` | Generate a new SSH keypair locally. |
| `ssh_keys` | `list(string)` | `[]` | List of additional public keys to authorize. |
| `set_root_password` | `bool` | `false` | Generate/set a random root password. |
| `set_user_password` | `bool` | `false` | Generate/set a random user password. |
| `lock_root_user_password`| `bool` | `false` | Lock the root account password. |
| `lock_user_password` | `bool` | `false` | Lock the user account password. |
| `disable_ssh_root_login` | `bool` | `true` | Disable SSH login for root user. |
| `enable_ssh_password_auth`| `bool` | `false` | Allow password authentication for SSH. |

#### System Management
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `package_update` | `bool` | `true` | Run `apt-get update` on first boot. |
| `package_upgrade` | `bool` | `true` | Run `apt-get upgrade` on first boot. |
| `packages` | `list(string)` | `[...]` | List of packages to install (e.g. `vim`, `git`). |
| `runcmds` | `list(string)` | `[...]` | List of arbitrary shell commands to run. |
| `manage_etc_hosts` | `bool` | `true` | Let Cloud-Init manage `/etc/hosts`. |
| `preserve_hostname` | `bool` | `true` | Preserve the hostname across reboots. |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `vm_ip_addresses` | Map of VM names to IP addresses. |
| `ssh_commands` | Ready-to-copy SSH connection strings. |
| `network_id` | ID of the created network. |
| `network_name` | Name of the network. |
| `pool_id` | ID of the storage pool. |
| `pool_name` | Name of the storage pool. |
| `root_password` | The generated root password (sensitive). |
| `user_password` | The generated user password (sensitive). |
| `ssh_user_name` | The configured username. |

## 🤝 Contributing

Contributions are welcome!
1. Fork the Project
2. Create your Feature Branch
3. Submit a Pull Request

## 📄 License

MIT License.