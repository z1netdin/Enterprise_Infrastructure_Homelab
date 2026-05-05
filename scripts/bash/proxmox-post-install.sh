#!/bin/bash
########################################
# Proxmox VE Post-Installation Setup
# Run this on the Proxmox host after install
########################################

set -euo pipefail

echo "=== Proxmox VE Post-Install Configuration ==="

# --- Remove enterprise repo (not needed for home lab) ---
echo "[1/6] Configuring apt repositories..."
if [ -f /etc/apt/sources.list.d/pve-enterprise.list ]; then
    sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list
fi

# Add no-subscription repository
cat > /etc/apt/sources.list.d/pve-no-subscription.list <<EOF
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
EOF

# --- Update system ---
echo "[2/6] Updating system packages..."
apt update && apt full-upgrade -y

# --- Install useful utilities ---
echo "[3/6] Installing utilities..."
apt install -y vim htop net-tools curl wget sudo iptables-persistent

# --- Configure lab bridge network (vmbr0 for 10.10.10.0/24) ---
echo "[4/6] Configuring lab bridge network..."

# Check if vmbr0 already has 10.10.10.1
if ! ip addr show vmbr0 2>/dev/null | grep -q "10.10.10.1"; then
    cat >> /etc/network/interfaces <<EOF

# Lab LAN bridge
auto vmbr0
iface vmbr0 inet static
    address 10.10.10.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
    post-up echo 1 > /proc/sys/net/ipv4/ip_forward
    post-up iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o vmbr0 -j MASQUERADE
    post-down iptables -t nat -D POSTROUTING -s 10.10.10.0/24 -o vmbr0 -j MASQUERADE
EOF
    echo "  vmbr0 bridge added to /etc/network/interfaces"
else
    echo "  vmbr0 already configured, skipping."
fi

# --- Enable IP forwarding ---
echo "[5/6] Enabling IP forwarding..."
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
fi

# --- Configure NAT for lab network internet access ---
echo "[6/6] Setting up NAT..."
WAN_IF=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$WAN_IF" ]; then
    iptables -t nat -C POSTROUTING -s 10.10.10.0/24 -o "$WAN_IF" -j MASQUERADE 2>/dev/null || \
        iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o "$WAN_IF" -j MASQUERADE
    netfilter-persistent save
    echo "  NAT configured on interface $WAN_IF"
else
    echo "  WARNING: Could not detect WAN interface. Configure NAT manually."
fi

echo ""
echo "=== Post-install complete ==="
echo "  Lab network: 10.10.10.0/24 on vmbr0"
echo "  Gateway:     10.10.10.1"
echo "  Web UI:      https://$(hostname -I | awk '{print $1}'):8006"
echo ""
echo "Next: Upload ISOs and create VMs."
