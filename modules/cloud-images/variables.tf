variable "os_name" {
  description = "Operating System name (e.g., ubuntu, debian, centos, fedora)"
  type        = string
  default     = "ubuntu"
}

variable "os_version" {
  description = "Operating System version (e.g., latest, 24.04, 22.04 for ubuntu)"
  type        = string
  default     = "latest"
}