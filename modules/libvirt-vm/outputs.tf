# Output the instance names
output "instance_names" {
  description = "List of VM instance names"
  value       = [for i in libvirt_domain.vm : i.name]
}

# Output the IP addresses of the instances
#output "instance_ips" {
#  description = "List of IP addresses for the VM instances"
#  value = [
#    for i in libvirt_domain.vm : i.network_interface[0].addresses[0]
#  ]
#}