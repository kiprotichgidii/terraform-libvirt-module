locals {
  url = local.os[var.os_name][var.os_version]
}

output "url" {
  value = local.url
}