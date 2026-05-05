# Enterprise Infrastructure Home Lab - Network Diagram

## Mermaid Diagram

Render this diagram at https://mermaid.live or in any Markdown viewer that supports Mermaid.

```mermaid
graph TB
    subgraph HOST["Windows 11 Host (i9-14900KF / 128GB RAM)"]
        subgraph HYPERV["Hyper-V / VMware Workstation"]
            subgraph PVE["Proxmox VE 8.x<br/>proxmox.lab.local<br/>Management: :8006"]
                subgraph VMBR0["vmbr0 - Lab LAN (10.10.10.0/24)"]
                    direction LR
                    GW["Gateway: 10.10.10.1"]
                end

                subgraph DC["win-dc01 (VM 100)<br/>10.10.10.10"]
                    AD["Active Directory DS"]
                    DNS["DNS Server"]
                    DHCP["DHCP Server"]
                    GPO["Group Policy"]
                    WA1["Wazuh Agent"]
                end

                subgraph WEB["rocky-web01 (VM 101)<br/>10.10.10.20"]
                    DOCKER["Docker Engine"]
                    NGINX["Nginx Web Server"]
                    GRAF["Grafana :3000"]
                    PROM["Prometheus :9090"]
                    WAZM["Wazuh Manager :1514"]
                    WA2["Wazuh Agent"]
                    ANS["Ansible Control Node"]
                end
            end
        end

        GH["GitHub Repository"]
        GHA["GitHub Actions CI/CD"]
        SN["ServiceNow Dev Instance"]
    end

    VMBR0 --> DC
    VMBR0 --> WEB
    DC <-->|"AD Auth / DNS"| WEB
    ANS -->|"SSH/WinRM"| DC
    ANS -->|"SSH"| WEB
    PROM -->|"Scrape metrics"| DC
    PROM -->|"Scrape metrics"| WEB
    PROM --> GRAF
    WA1 -->|"Events :1514"| WAZM
    WA2 -->|"Events :1514"| WAZM
    GHA -->|"Ansible/Terraform"| PVE
    GH <-->|"Git Push"| HOST
    SN <-->|"REST API"| WEB

    style HOST fill:#1a1a2e,stroke:#e94560,color:#fff
    style PVE fill:#0f3460,stroke:#16213e,color:#fff
    style DC fill:#533483,stroke:#e94560,color:#fff
    style WEB fill:#2b2d42,stroke:#8d99ae,color:#fff
    style VMBR0 fill:#16213e,stroke:#0f3460,color:#fff
```

## ASCII Diagram (for terminals and plain text)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    WINDOWS 11 HOST                                      │
│              i9-14900KF / 128GB RAM / 769GB                            │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │              PROXMOX VE 8.x (Nested Virtualization)              │  │
│  │              Management UI: https://proxmox:8006                  │  │
│  │                                                                   │  │
│  │  ┌─────────── vmbr0: 10.10.10.0/24 (Lab LAN) ─────────────┐    │  │
│  │  │                    GW: 10.10.10.1                        │    │  │
│  │  │                                                          │    │  │
│  │  │  ┌──────────────────┐       ┌──────────────────────┐    │    │  │
│  │  │  │   win-dc01       │       │   rocky-web01        │    │    │  │
│  │  │  │   10.10.10.10    │       │   10.10.10.20        │    │    │  │
│  │  │  │                  │       │                      │    │    │  │
│  │  │  │  Win Server 2025 │◄─────►│  Rocky Linux 9       │    │    │  │
│  │  │  │                  │ AD/DNS│                      │    │    │  │
│  │  │  │  ┌────────────┐  │       │  ┌────────────────┐  │    │    │  │
│  │  │  │  │ AD DS      │  │       │  │ Docker         │  │    │    │  │
│  │  │  │  │ DNS        │  │       │  │  ├─ Nginx      │  │    │    │  │
│  │  │  │  │ DHCP       │  │       │  │  ├─ Grafana    │  │    │    │  │
│  │  │  │  │ GPO        │  │       │  │  ├─ Prometheus │  │    │    │  │
│  │  │  │  │ Wazuh Agent│  │       │  │  └─ Wazuh Mgr  │  │    │    │  │
│  │  │  │  └────────────┘  │       │  ├─ Ansible       │  │    │    │  │
│  │  │  │                  │       │  └─ Wazuh Agent    │  │    │    │  │
│  │  │  └──────────────────┘       └──────────────────────┘    │    │  │
│  │  └──────────────────────────────────────────────────────────┘    │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                                                                         │
│  External Services:                                                     │
│    ├─ GitHub + GitHub Actions ──► Ansible/Terraform ──► Proxmox API    │
│    └─ ServiceNow Dev Instance ◄──► REST API ──► rocky-web01            │
└─────────────────────────────────────────────────────────────────────────┘

Ports/Protocols:
  22/TCP    SSH (Linux)          3000/TCP  Grafana
  5985/TCP  WinRM (Windows)      9090/TCP  Prometheus
  8006/TCP  Proxmox Web UI       1514/TCP  Wazuh Agent
  53/UDP    DNS                  1515/TCP  Wazuh Registration
  80/TCP    HTTP (Nginx)         443/TCP   HTTPS
  443/TCP   HTTPS                9100/TCP  Node Exporter
```

## Service Map

| Service         | Host         | Port  | Protocol | Purpose                    |
|-----------------|--------------|-------|----------|----------------------------|
| Proxmox Web UI  | 10.10.10.1   | 8006  | HTTPS    | Hypervisor management      |
| Active Directory| 10.10.10.10  | 389   | LDAP     | Directory services         |
| DNS             | 10.10.10.10  | 53    | UDP/TCP  | Name resolution            |
| DHCP            | 10.10.10.10  | 67-68 | UDP      | IP address assignment      |
| WinRM           | 10.10.10.10  | 5985  | HTTP     | Windows remote management  |
| SSH             | 10.10.10.20  | 22    | TCP      | Linux remote access        |
| Nginx           | 10.10.10.20  | 80    | HTTP     | Web server                 |
| Grafana         | 10.10.10.20  | 3000  | HTTP     | Monitoring dashboards      |
| Prometheus      | 10.10.10.20  | 9090  | HTTP     | Metrics collection         |
| Node Exporter   | 10.10.10.20  | 9100  | HTTP     | Host metrics               |
| Wazuh Manager   | 10.10.10.20  | 1514  | TCP      | SIEM event collection      |
| Wazuh API       | 10.10.10.20  | 55000 | HTTPS    | Wazuh management API       |
| Wazuh Dashboard | 10.10.10.20  | 5601  | HTTPS    | Security dashboard         |
