# Terraform Libvirt Module

This Terraform module uses the `libvirt` provider to create virtual machines (VMs), manage disks, and network interfaces. It also manages storage pools for the VMs. The module is designed to be flexible, allowing you to create one or more VM instances, attach multiple disks and network interfaces, and manage your storage pools.

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
1. Install Terraform and libvirt.

2. Clone this repository and navigate to the terraform directory.
```bash
$ git clone https://github.com/giddy624/terraform-libvirt-module.git
```
3. Navigate to `terraform-libvirt/terraform/examples/` then modify the main.tf file according to your environment.
```bash
$ cd terraform-libvirt/terraform/examples/main.tf
```
4. Initialize Terraform with:
```bash
$ terraform init
``` 
5. Run terraform plan.
```bash
$ terraform plan
```
6. Apply the configuration to create the VMs:
```bash
$ terraform apply
```

7. Confirm the resources to be created and monitor the output for the VMs and their IP addresses.

### Example 1: Basic Usage with main.tf
```hcl
module "libvirt_vms" {
  source            = "../modules/libvirt-vm"
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