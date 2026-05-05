########################################
# Proxmox Connection Variables
########################################

variable "proxmox_url" {
  description = "Proxmox API URL (e.g., https://10.10.10.1:8006)"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user (e.g., root@pam)"
  type        = string
  default     = "root@pam"
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "proxmox"
}

########################################
# Storage
########################################

variable "storage_pool" {
  description = "Proxmox storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

########################################
# ISO Filenames
########################################

variable "windows_iso" {
  description = "Windows Server 2025 ISO filename (as uploaded to Proxmox)"
  type        = string
  default     = "windows-server-2025.iso"
}

variable "rocky_iso" {
  description = "Rocky Linux 9 ISO filename (as uploaded to Proxmox)"
  type        = string
  default     = "rocky-linux-9.iso"
}

variable "virtio_iso" {
  description = "VirtIO drivers ISO filename"
  type        = string
  default     = "virtio-win.iso"
}
