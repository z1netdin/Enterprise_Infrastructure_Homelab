output "win_dc01_vm_id" {
  description = "VM ID for the Windows Server 2025 Domain Controller"
  value       = proxmox_virtual_environment_vm.win_dc01.vm_id
}

output "rocky_web01_vm_id" {
  description = "VM ID for the Rocky Linux 9 server"
  value       = proxmox_virtual_environment_vm.rocky_web01.vm_id
}
