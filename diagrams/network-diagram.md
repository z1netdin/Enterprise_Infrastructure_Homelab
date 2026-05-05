# Network Diagram

```
VMware Workstation (Windows 11)
|
|-- Proxmox VE 9.1
|     Web UI on port 8006
|
|-- win-dc01 (Windows Server 2025)
|     Active Directory
|     DNS
|     DHCP
|     Group Policy
|
|-- rocky-web01 (Rocky Linux 10)
      Docker containers:
        Nginx          port 80
        Grafana        port 3000
        Prometheus     port 9091
        Node Exporter  port 9100
        Wazuh Manager  port 1514
        Wazuh Indexer  port 9200
        Wazuh Dashboard port 443
```

All VMs on VMware NAT network (192.168.187.0/24).
