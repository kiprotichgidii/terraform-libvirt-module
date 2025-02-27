## How to Use
1. Install Terraform and libvirt.

2. Clone this repository and navigate to the terraform directory.

3. Modify the terragrunt.hcl or main.tf file according to your environment. Then navigate to `terraform-libvirt/terraform/modules/main.tf`
```bash
$ cd terraform-libvirt/terraform/examples/basic-usage/main.tf
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

### Notes
The `libvirt` provider requires a running `libvirtd` service. Ensure your system has this service installed and running.
Customize the `disks` and `network_interfaces` variables to suit your requirements.

### Troubleshooting
Ensure that the libvirt service is running:
```bash
$ sudo systemctl status libvirtd
```

If you encounter errors, check the **logs** in `/var/log/libvirt/` for more details.