# Phase 1: Proxmox VE Setup with Nested Virtualization

## Overview

We install Proxmox VE as a VM on Windows 11 using Hyper-V (free, built-in) with nested virtualization enabled. This lets Proxmox manage its own VMs inside the Hyper-V VM — the standard approach for home labs on a daily-driver machine.

**Host specs used:** Intel i9-14900KF, 128GB RAM, 769GB free disk

## Prerequisites

- Windows 11 Pro/Home with Hyper-V or VMware Workstation
- Proxmox VE 8.x ISO: https://www.proxmox.com/en/downloads
- Windows Server 2025 Evaluation ISO: https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2025
- Rocky Linux 9 Minimal ISO: https://rockylinux.org/download

## Step 1: Enable Hyper-V on Windows 11

> **Note:** If you have Windows 11 Home, Hyper-V is not available by default. Use the enablement script at `scripts/powershell/Enable-HyperV-Home.ps1` or use VMware Workstation Player (free for personal use) instead. Skip to Step 1B for VMware.

### Step 1A: Hyper-V (Windows 11 Pro/Enterprise)

Open PowerShell as Administrator:

```powershell
# Enable Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

# Restart when prompted
Restart-Computer
```

### Step 1B: VMware Workstation (Alternative — works on Home edition)

1. Download and install VMware Workstation Player/Pro
2. During VM creation, enable "Virtualize Intel VT-x/EPT or AMD-V/RVI" in Processors settings
3. Continue with Step 3 below (VMware handles nested virtualization automatically)

## Step 2: Enable Nested Virtualization for Hyper-V

After reboot, open PowerShell as Administrator:

```powershell
# Create the Proxmox VM first (Step 3), then enable nested virtualization on it:
Set-VMProcessor -VMName "Proxmox-VE" -ExposeVirtualizationExtensions $true
```

## Step 3: Create the Proxmox VE Virtual Machine

### Using Hyper-V Manager:

1. Open **Hyper-V Manager**
2. Click **New > Virtual Machine**
3. Configure:
   - **Name:** Proxmox-VE
   - **Generation:** Generation 2 (UEFI)
   - **Memory:** 32768 MB (32GB) — startup memory, disable dynamic memory
   - **Network:** Default Switch (or create an Internal Switch named "LabSwitch")
   - **Hard Disk:** 200GB (dynamically expanding)
   - **Installation:** Mount the Proxmox VE ISO

4. Before starting, adjust settings:
   - **Processor:** 8 virtual processors
   - **Security:** Disable Secure Boot (Proxmox uses Linux bootloader)
   - **Memory:** Uncheck "Enable Dynamic Memory"

5. Enable nested virtualization (if not done in Step 2):
   ```powershell
   Set-VMProcessor -VMName "Proxmox-VE" -ExposeVirtualizationExtensions $true
   ```

6. Add a second network adapter (Internal Switch) for the lab network:
   ```powershell
   # Create an internal switch for the lab network
   New-VMSwitch -Name "LabSwitch" -SwitchType Internal

   # Assign an IP to the host-side of the internal switch
   New-NetIPAddress -InterfaceAlias "vEthernet (LabSwitch)" -IPAddress 10.10.10.254 -PrefixLength 24

   # Add the switch to the Proxmox VM
   Add-VMNetworkAdapter -VMName "Proxmox-VE" -SwitchName "LabSwitch"
   ```

### Automated setup:

Run `scripts/powershell/Create-ProxmoxVM.ps1` to automate the entire VM creation process.

## Step 4: Install Proxmox VE

1. Start the VM and boot from the ISO
2. Select **Install Proxmox VE (Graphical)**
3. Accept the EULA
4. Select the target disk (the 200GB virtual disk)
5. Set location and timezone
6. Set the root password (document it securely — you'll need it)
7. Network configuration:
   - **Management Interface:** The network adapter connected to Default Switch
   - **Hostname:** proxmox.lab.local
   - **IP Address:** Leave as DHCP-assigned for management, or set static
   - **Gateway:** As provided by Hyper-V Default Switch
   - **DNS:** 8.8.8.8 (or your preferred DNS)
8. Review and click **Install**
9. After reboot, remove the ISO and access the web UI

## Step 5: Access Proxmox Web Interface

After installation, Proxmox displays its management URL on the console:

```
https://<proxmox-ip>:8006
```

1. Open a browser on your Windows host
2. Navigate to the URL shown
3. Accept the self-signed certificate warning
4. Log in with:
   - **Username:** root
   - **Realm:** Linux PAM
   - **Password:** (the one you set during install)

## Step 6: Configure Proxmox Networking for the Lab

In the Proxmox web UI:

1. Go to **Datacenter > proxmox > System > Network**
2. Create a new **Linux Bridge**:
   - **Name:** vmbr0
   - **IPv4/CIDR:** 10.10.10.1/24
   - **Comment:** Lab LAN
   - **Bridge ports:** (leave empty — this is an internal-only bridge)
3. Click **Apply Configuration**

This bridge provides the 10.10.10.0/24 network for all lab VMs.

## Step 7: Enable NAT for Internet Access (on Proxmox host)

SSH into the Proxmox host or use the console:

```bash
# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Add NAT rule (replace ens18 with your actual WAN interface name)
# Check interface name with: ip addr
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o ens18 -j MASQUERADE

# Make iptables rules persistent
apt install -y iptables-persistent
netfilter-persistent save
```

## Step 8: Upload ISOs to Proxmox

1. In the Proxmox web UI, go to **Datacenter > proxmox > local (proxmox) > ISO Images**
2. Click **Upload** and upload:
   - Windows Server 2025 ISO
   - Rocky Linux 9 Minimal ISO
   - VirtIO drivers ISO (download from https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso — required for Windows VMs on Proxmox)

## Step 9: Create VMs in Proxmox

### Windows Server 2025 VM (win-dc01)

1. Click **Create VM** in the top right
2. **General:**
   - VM ID: 100
   - Name: win-dc01
3. **OS:**
   - ISO: Windows Server 2025 ISO
   - Type: Microsoft Windows
   - Version: 11/2022/2025
4. **System:**
   - BIOS: OVMF (UEFI)
   - Add EFI Disk: Yes
   - SCSI Controller: VirtIO SCSI single
   - Add TPM: v2.0
5. **Disks:**
   - Bus: VirtIO Block
   - Size: 80GB
   - Add second CD/DVD: VirtIO drivers ISO
6. **CPU:** 4 cores, type: host
7. **Memory:** 8192 MB (8GB)
8. **Network:** Bridge: vmbr0, Model: VirtIO
9. **Confirm and create** (do NOT start yet)

### Rocky Linux 9 VM (rocky-web01)

1. Click **Create VM**
2. **General:**
   - VM ID: 101
   - Name: rocky-web01
3. **OS:**
   - ISO: Rocky Linux 9 Minimal ISO
   - Type: Linux
   - Version: 6.x - 2.6 Kernel
4. **System:**
   - BIOS: OVMF (UEFI)
   - Add EFI Disk: Yes
   - SCSI Controller: VirtIO SCSI single
5. **Disks:**
   - Bus: VirtIO Block
   - Size: 80GB
6. **CPU:** 4 cores, type: host
7. **Memory:** 8192 MB (8GB)
8. **Network:** Bridge: vmbr0, Model: VirtIO
9. **Confirm and create**

## Step 10: Install the Operating Systems

### Windows Server 2025

1. Start VM 100 (win-dc01)
2. Open the console
3. Boot from the ISO and begin Windows Setup
4. Select **Windows Server 2025 Standard (Desktop Experience)**
5. When asked for disk drivers, click **Load driver** and browse the VirtIO CD:
   - Select `vioscsi\2k25\amd64` for the storage driver
   - Select `NetKVM\2k25\amd64` for the network driver
6. Install to the VirtIO disk
7. Set administrator password
8. After install, install remaining VirtIO drivers from the VirtIO CD (run `virtio-win-guest-tools.exe`)
9. Set static IP:
   - IP: 10.10.10.10
   - Subnet: 255.255.255.0
   - Gateway: 10.10.10.1
   - DNS: 10.10.10.10 (will be its own DNS server after AD setup)

### Rocky Linux 9

1. Start VM 101 (rocky-web01)
2. Open the console
3. Select **Install Rocky Linux 9**
4. Configure:
   - **Software Selection:** Minimal Install
   - **Installation Destination:** Select the VirtIO disk
   - **Network:** Enable the network adapter, set:
     - IP: 10.10.10.20
     - Subnet: 255.255.255.0
     - Gateway: 10.10.10.1
     - DNS: 10.10.10.10 (will point to AD DNS once configured)
   - **Root Password:** Set a strong password
   - **User Creation:** Create an admin user
5. Begin installation and reboot when complete

## Verification Checklist

After completing all steps, verify:

- [ ] Proxmox web UI accessible at https://<proxmox-ip>:8006
- [ ] vmbr0 bridge created with 10.10.10.1/24
- [ ] win-dc01 VM created and Windows Server 2025 installed
- [ ] rocky-web01 VM created and Rocky Linux 9 installed
- [ ] Both VMs can ping 10.10.10.1 (Proxmox gateway)
- [ ] Both VMs can ping each other (10.10.10.10 <-> 10.10.10.20)
- [ ] Both VMs have internet access (ping 8.8.8.8)
- [ ] Screenshot: Proxmox dashboard showing both VMs running

## Next Steps

Proceed to [Phase 2: Windows Server 2025 — Active Directory Setup](02-windows-server-setup.md)
