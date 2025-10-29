# Outputs for the network resource
output "network_id" {
  description = "ID of the libvirt network"
  value       = try(libvirt_network.network[0].id, "N/A")
}

output "network_name" {
  description = "Name of the libvirt network"
  value       = try(libvirt_network.network[0].name, "N/A")
}

# Outputs for the storage pool
output "pool_id" {
  description = "ID of the libvirt storage pool"
  value       = try(libvirt_pool.storage_pool[0].id, "N/A")
}

output "pool_name" {
  description = "Name of the libvirt storage pool"
  value       = try(libvirt_pool.storage_pool[0].name, "N/A")
}

# Outputs for the libvirt VM
output "ssh_user_name" {
  description = "The SSH username for the VM"
  value       = var.user_name
}

output "root_password" {
  description = "The root password for the VM (if set_root_password is true)"
  value       = var.set_root_password ? random_password.root_password[0].result : ""
  sensitive   = true
}

output "user_password" {
  description = "The user password for the VM (if set_user_password is true)"
  value       = var.set_user_password ? random_password.user_password[0].result : ""
  sensitive   = true
}

output "vm_ip_addresses" {
  description = "List of IP addresses assigned to the VM(s)"
  value = {
    for idx, vm in libvirt_domain.vm_domain :
    vm.name => (
      var.network_mode == "bridge" && var.enable_dhcp ? (
        try(vm.network_interface[0].addresses[0], "N/A")
        ) : (
        var.network_mode != "bridge" && var.ip_address != "" ? var.ip_address : "N/A"
      )
    )
  }
}

output "ssh_commands" {
  description = "SSH commands to connect to the VM(s)"
  value = {
    for idx, vm in libvirt_domain.vm_domain :
    vm.name => (
      var.network_mode == "bridge" && var.enable_dhcp ? (
        format("ssh -i %s %s@%s", "${path.cwd}/sshkey.priv", var.user_name, try(vm.network_interface[0].addresses[0], "N/A"))
        ) : (
        var.network_mode != "bridge" && var.ip_address != "" ? (
          format("ssh -i %s %s@%s", "${path.cwd}/id_rsa.key", var.user_name, var.ip_address)
          ) : (
          "N/A"
        )
      )
    )
  }
  sensitive = false
}