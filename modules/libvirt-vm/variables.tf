# Provider Variables
variable "livirt_uri" {
  description = "KVM Host connection URI"
  type        = string
  default     = "qemu:///system"
}

# Cloud Images Module Variables
variable "os_name" {
  description = "Operating System name (e.g., ubuntu, centos-stream)"
  type        = string
  default     = "ubuntu"
}
variable "os_version" {
  description = "Operating System version (e.g., latest, 24.04, 22.04 for ubuntu)"
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

# Storage Pool Variables
variable "create_storage_pool" {
  description = "Whether to create a new libvirt storage pool"
  type        = bool
  default     = false
}

variable "storage_pool_name" {
  description = "Name of the libvirt storage pool"
  type        = string
  default     = "default_pool"
}

variable "storage_pool_type" {
  description = "Type of the storage pool (e.g., dir, fs, logical, netfs)"
  type        = string
  default     = "dir"
}

variable "storage_pool_path" {
  description = "Path for the storage pool (applicable for dir and fs types)"
  type        = string
  default     = "/var/lib/libvirt/images"
}

# Random Resource Variables
variable "set_root_password" {
  description = "Whether to enable seting a random root password"
  type        = bool
  default     = false
}

variable "set_user_password" {
  description = "Whether to enable seting a random user password"
  type        = bool
  default     = false
}

variable "user_name" {
  description = "Username for the default user to create"
  type        = string
  default     = "cloud-user"
}

variable "ssh_keys" {
  description = "List of SSH public keys to add to the default user"
  type        = list(string)
  default     = []
}

# Files Creation Variables
variable "generate_ssh_key" {
  description = "Whether to generate an SSH key pair for VM access"
  type        = bool
  default     = true
}

# Libvirt Volume Variables
variable "vm_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
}

# Cloud Init Variables
variable "timezone" {
  description = "Timezone for the VM"
  type        = string
  default     = "UTC"
}

variable "enable_ssh_password_auth" {
  description = "Whether to enable SSH password authentication"
  type        = bool
  default     = false
}

variable "disable_ssh_root_login" {
  description = "Whether to disable SSH root login"
  type        = bool
  default     = true
}

variable "lock_root_user_password" {
  description = "Whether to lock the root user password"
  type        = bool
  default     = false
}

variable "lock_user_password" {
  description = "Whether to lock the default user password"
  type        = bool
  default     = false
}

variable "ssh_user_fullname" {
  description = "Full name for the default user"
  type        = string
  default     = "Cloud User"
}

variable "ssh_user_shell" {
  description = "Login shell for the default user"
  type        = string
  default     = "/bin/bash"
}

variable "manage_etc_hosts" {
  description = "Whether to manage /etc/hosts file"
  type        = bool
  default     = true
}

variable "preserve_hostname" {
  description = "Whether to preserve the hostname"
  type        = bool
  default     = true
}

variable "packages" {
  description = "List of packages to install on the VM"
  type        = list(string)
  default = [
    "qemu-guest-agent",
    "vim",
    "wget",
    "curl",
    "unzip",
    "git"
  ]
}

variable "runcmds" {
  description = "Extra commands to be run with cloud init"
  type        = list(string)
  default = [
    "systemctl daemon-reload",
    "systemctl enable --now qemu-guest-agent",
    "systemctl restart systemd-networkd"
  ]
}

variable "disable_ipv6" {
  description = "Whether to disable IPv6 on the VM"
  type        = bool
  default     = true
}

variable "package_update" {
  description = "Whether to update package lists on first boot"
  type        = bool
  default     = true
}

variable "package_upgrade" {
  description = "Whether to upgrade packages on first boot"
  type        = bool
  default     = true
}

variable "ip_address" {
  description = "Static IP address for the VM (if empty, DHCP is used)"
  type        = string
  default     = "172.20.0.10/24"
}

variable "ip_gateway" {
  description = "Gateway IP address for the VM (required if static IP is set)"
  type        = string
  default     = "172.20.0.1"
}

variable "network_interface" {
  description = "Network interface to use for the VM (e.g., eth0)"
  type        = string
  default     = "eth0"
}

variable "dns_servers" {
  description = "List of DNS servers for the VM"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# Virtual Machine Variables
variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "Ubuntu"
}

variable "memory" {
  description = "Memory size for the VM in MB"
  type        = number
  default     = 4096
}

variable "vcpu" {
  description = "Number of virtual CPUs for the VM"
  type        = number
  default     = 2
}

variable "cpu_mode" {
  description = "CPU mode for the VM (e.g., host-model, host-passthrough)"
  type        = string
  default     = "host-passthrough"
}

variable "autostart_vm" {
  description = "Whether the VM should autostart on host boot"
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "Disk size for the VM in GB"
  type        = number
  default     = 20
}

variable "graphics_listen_address" {
  description = "The address graphics should listen on"
  type        = string
  default     = "127.0.0.1"
}