########################################
# Enterprise Infrastructure Home Lab
# Terraform - Proxmox VM Provisioning
########################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.50.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_url
  username = var.proxmox_user
  password = var.proxmox_password
  insecure = true # Self-signed cert in lab environment
}

########################################
# Windows Server 2025 - Domain Controller
########################################

resource "proxmox_virtual_environment_vm" "win_dc01" {
  name      = "win-dc01"
  node_name = var.proxmox_node
  vm_id     = 100

  description = "Windows Server 2025 - Active Directory Domain Controller"
  tags        = ["windows", "domain-controller", "phase2"]

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.storage_pool
    size         = 80
    interface    = "virtio0"
    file_format  = "raw"
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/${var.windows_iso}"
    interface = "ide0"
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/${var.virtio_iso}"
    interface = "ide1"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "win11"
  }

  bios = "ovmf"

  efi_disk {
    datastore_id = var.storage_pool
    type         = "4m"
  }

  tpm_state {
    datastore_id = var.storage_pool
    version      = "v2.0"
  }

  on_boot = false
}

########################################
# Rocky Linux 9 - Web/Docker Server
########################################

resource "proxmox_virtual_environment_vm" "rocky_web01" {
  name      = "rocky-web01"
  node_name = var.proxmox_node
  vm_id     = 101

  description = "Rocky Linux 9 - Docker, Web Services, Monitoring, SIEM"
  tags        = ["linux", "docker", "monitoring", "phase3"]

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = var.storage_pool
    size         = 80
    interface    = "virtio0"
    file_format  = "raw"
  }

  cdrom {
    enabled   = true
    file_id   = "local:iso/${var.rocky_iso}"
    interface = "ide0"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  operating_system {
    type = "l26"
  }

  bios = "ovmf"

  efi_disk {
    datastore_id = var.storage_pool
    type         = "4m"
  }

  on_boot = false
}
