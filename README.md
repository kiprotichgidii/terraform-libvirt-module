# Terraform/OpenTofu Libvirt Module

This Terraform/OpenTofu module uses the `libvirt` provider to create virtual machines (VMs), manage disks, and network interfaces. It also manages storage pools for the VMs. The module is designed to be flexible, allowing you to create one or more VM instances, attach multiple disks and network interfaces, and manage your storage pools.

## Features

- Create one or multiple VM instances
- Attach one or more disks to each instance
- Attach one or more network interfaces to each instance
- Manage storage pools of type `dir`

## Requirements

- **Terraform v1.0.0 or above**
- `libvirt`zprovider
- A running instance of `libvirtd`

## How to Use
Install Terraform and libvirt, then specify the resources to be created in your `main.tf` file:

**Example `main.tf`:**

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
  uri = "qemu+ssh://tofu@192.168.1.20/system?sshauth=privkey&keyfile=~/.ssh/id_ecdsa&no_verify=1"
}

module "libvirt_vm" {
  source = "git::https://github.com/kiprotichgidii/terraform-libvirt-module.git//modules/libvirt-vm?ref=main"

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
  vm_name    = "Ubuntu"
  vm_count   = 1
  memory     = 2048
  vcpu       = 2
  disk_size  = 20
  graphics_listen_address = "0.0.0.0"
  timezone   = "Africa/Nairobi"
  ip_address = ""
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

Initialize Terraform with:
```bash
$ terraform init
``` 
Run terraform plan:
```bash
$ terraform plan
```
Apply the configuration to create the VMs:
```bash
$ terraform apply
```

### Inputs

| Name                 | Description                       | Type   | Default                    | Required |
|----------------------|-----------------------------------|--------|----------------------------|----------|
| `instance_name`      | Base name for the VM instance(s)  | string | `"example-vm"`             | Yes      |
| `instance_count`     | Number of VM instances to create  | number | `1`                        | No       |
| `memory`             | Amount of memory for the VM in MB | number | `1024`                     | No       |
|  `vcpu`              | Number of virtual CPUs for the VM | number | `1`                        | No       |
|  `disks`             | List of disks to attach to the VM |  list  | `[{ size = 10 }]`          | No       |
|                      |   (size in GB)                    |        |                            |          |
|`storage_pool_name`   | Name of the storage pool where    | string |  `default`                 |  No      |
|                      |  the disks will be created        |        |                            |          |
|`storage_pool_path`   | Path to the directory used for    |string  |`"/var/lib/libvirt/images"` |          |
|                      | the storage pool                  |        |                            |          |
| `network_interfaces` | List of network interfaces to     | list   | `[{ name = "k8snet" }]`   | No       |
|                      |  attach to the VM                 |        |                            |          |

### Outputs
|Name	        | Description                      |
|---------------|----------------------------------|
|instance_names	| List of VM instance names        |
|instance_ips	| List of IP addresses for the VMs |
|---------------|----------------------------------|

### Notes
The `libvirt` provider requires a running `libvirtd` service. Ensure your system has this service installed and running.
Customize the `disks` and `network_interfaces` variables to suit your requirements.

### Troubleshooting
Ensure that the libvirt service is running:
```bash
$ sudo systemctl status libvirtd
```

If you encounter errors, check the **logs** in `/var/log/libvirt/` for more details.