# Provider Variables
variable "livirt_uri" {
  description = "KVM Host connection URI"
  type        = string
  default     = "qemu+ssh://root@192.168.1.100/system"
}

# Cloud Images Module Variables
variable "os_name" {
  description = "Operating System name (e.g., ubuntu, centos-stream, debian, almalinux, rockylinux, oraclelinux, fedora, alpine, amazonlinux, opensuse, archlinux, freebsd)"
  type        = string
  default     = "ubuntu"
}
variable "os_version" {
  description = "Operating System version (e.g., latest, 24.04, 22.04 for ubuntu; latest, 9, 8 for rockylinux; latest, 9, 8 for almalinux; latest, 9, 8 for oraclelinux; latest, 10, 9 for centos-stream; latest, 12, 11, 10 for debian; latest, 42, 41 for fedora; latest, 3.21, 3.20 for alpine; latest, 2023 for amazonlinux; latest, 15.6, 15.5 for opensuse; latest for archlinux; latest, 14 for freebsd)"
  type        = string
  default     = "latest"
}

# Network Variables
variable "create_network" {
  description = "Whether to create a new libvirt network"
  type        = bool
  default     = true
}

variable "network_name" {
  description = "Name of the libvirt network"
  type        = string
  default     = "default_01"
}

variable "network_mode" {
  description = "Network mode: nat, bridge, or routed"
  type        = string
  default     = "nat"
}

variable "autostart_network" {
  description = "Whether the network should autostart on host boot"
  type        = bool
  default     = true
}

variable "network_cidr" {
  description = "CIDR for the network (applicable for nat and routed modes)"
  type        = list(string)
  default     = ["172.20.0.0/24"]
}

variable "network_mtu" {
  description = "MTU for the network (applicable for nat and routed modes)"
  type        = number
  default     = 1500
}

variable "enable_dhcp" {
  description = "Whether to enable DHCP server for the network"
  type        = bool
  default     = true
}
variable "dhcp_range_start" {
  description = "Start of DHCP range (only for bridge mode with DHCP enabled)"
  type        = string
  default     = "172.20.0.1"
}

variable "dhcp_range_end" {
  description = "End of DHCP range (only for bridge mode with DHCP enabled)"
  type        = string
  default     = "172.20.0.254"
}

# Storage Pool Variables