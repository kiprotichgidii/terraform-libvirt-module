# General instance settings
variable "instance_name" {
  description = "Base name for the VM instance(s)"
  type        = string
}

variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = 1
}

# VM hardware settings
variable "memory" {
  description = "Amount of memory for the VM in MB"
  type        = number
  default     = 2048
}

variable "vcpu" {
  description = "Number of virtual CPUs for the VM"
  type        = number
  default     = 2
}

# Storage settings
variable "disks" {
  description = "List of disks to be attached."
  type = list(object({
    size   = optional(number)
  }))
}


variable "storage_pool_name" {
  description = "Name of the storage pool where the disks will be created"
  type        = string
  default     = "default"
}

variable "storage_pool_path" {
  description = "Path to the directory used for the storage pool"
  type        = string
  default     = "/var/lib/libvirt/images"
}

variable "cdrom_path" {
  description = "Path to the ISO file to attach as a bootable CD-ROM"
  type        = string
  default     = "/path/to/your/bootable.iso" # Replace with your ISO file path
}


variable "disk_format" {
  description = "Disk format for the VM image (e.g., qcow2, raw, iso)"
  type        = string
  default     = "qcow2"
}

# Network settings
variable "network_interfaces" {
  description = "List of network interfaces to attach to the VM. Each entry must have a name."
  type = list(object({
    name = string
  }))
  default = [
    {
      name = "default"
    }
  ]
}

