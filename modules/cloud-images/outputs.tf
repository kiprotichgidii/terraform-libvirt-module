locals {
  url = local.os[var.os_name][var.os_version]
  available = can(local.os[var.os_name][var.os_version])
}

output "url" {
  description = "URL of the cloud image to download"
  value       = local.url
}

output "available" {
  description = "Whether the requested OS image is available"
  value       = local.available
}