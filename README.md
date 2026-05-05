# Enterprise Infrastructure Home Lab

## Problem Statement

Organizations need IT professionals who can deploy, manage, and secure enterprise infrastructure across hybrid environments. This project demonstrates hands-on proficiency with the full stack of tools used in enterprise system administration — from hypervisor-level virtualization to automated configuration management, security monitoring, and CI/CD pipelines.

Built to demonstrate the skills required for enterprise Lab/System Administration roles, including those at organizations like ASRC Federal.

## Solution

A fully functional enterprise infrastructure lab running on a single workstation, featuring:

- **Virtualization** — Proxmox VE hypervisor managing Windows and Linux VMs
- **Directory Services** — Windows Server 2025 Active Directory with DNS, DHCP, and Group Policy
- **Linux Administration** — Rocky Linux 10 running web services and containers
- **Containerization** — Docker with multi-service deployments
- **Infrastructure as Code** — Terraform provisioning VMs on Proxmox
- **Configuration Management** — Ansible automating OS and application configuration
- **Monitoring** — Grafana + Prometheus dashboards with alerting
- **Security (SIEM)** — Wazuh monitoring all endpoints for threats and compliance
- **Automation** — Bash, PowerShell, and Python scripts for operational tasks
- **CI/CD** — GitHub Actions pipelines for automated testing and deployment
- **Ticketing** — ServiceNow developer instance for change management

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│  Windows 11 Host (i9-14900KF / 128GB RAM / 769GB Disk)            │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Proxmox VE 8.x (Hyper-V Nested Virtualization)              │  │
│  │  Management: https://proxmox:8006                             │  │
│  │                                                               │  │
│  │  ┌─────────────────────┐  ┌─────────────────────────────┐   │  │
│  │  │ VM: win-dc01        │  │ VM: rocky-web01              │   │  │
│  │  │ Windows Server 2025 │  │ Rocky Linux 9                │   │  │
│  │  │ 4 vCPU / 8GB RAM    │  │ 4 vCPU / 8GB RAM            │   │  │
│  │  │                     │  │                               │   │  │
│  │  │ - Active Directory  │  │ - Docker Host                │   │  │
│  │  │ - DNS Server        │  │ - Nginx Web Server           │   │  │
│  │  │ - DHCP Server       │  │ - Grafana + Prometheus       │   │  │
│  │  │ - Group Policy      │  │ - Wazuh Manager              │   │  │
│  │  │ - Wazuh Agent       │  │ - Ansible Control Node       │   │  │
│  │  │                     │  │ - Wazuh Agent                │   │  │
│  │  └─────────────────────┘  └─────────────────────────────┘   │  │
│  │                                                               │  │
│  │  Network: 10.10.10.0/24 (vmbr0 - Lab LAN)                   │  │
│  │  Gateway: 10.10.10.1 (Proxmox)                               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  GitHub Actions ←→ Ansible/Terraform ←→ Proxmox API               │
│  ServiceNow Dev Instance ←→ REST API Integration                   │
└─────────────────────────────────────────────────────────────────────┘
```

## Network Layout

| Host            | IP Address    | OS                   | Role                              |
|-----------------|---------------|----------------------|-----------------------------------|
| proxmox         | 10.10.10.1    | Proxmox VE 8.x      | Hypervisor, gateway               |
| win-dc01        | 10.10.10.10   | Windows Server 2025  | AD DC, DNS, DHCP, GPO            |
| rocky-web01     | 10.10.10.20   | Rocky Linux 9        | Docker, web, monitoring, SIEM    |

## Tech Stack

| Category               | Tool                          |
|------------------------|-------------------------------|
| Hypervisor             | Proxmox VE 8.x               |
| Windows Server         | Windows Server 2025           |
| Linux Server           | Rocky Linux 9                 |
| Containers             | Docker + Docker Compose       |
| IaC                    | Terraform (Proxmox provider)  |
| Config Management      | Ansible                       |
| Monitoring             | Grafana + Prometheus          |
| SIEM                   | Wazuh                         |
| Scripting              | Bash, PowerShell, Python      |
| Version Control        | Git + GitHub                  |
| CI/CD                  | GitHub Actions                |
| Ticketing              | ServiceNow (Dev Instance)     |

## Project Structure

```
.
├── README.md
├── docs/
│   ├── setup-guides/          # Step-by-step setup documentation
│   └── screenshots/           # Configuration screenshots
├── terraform/
│   └── proxmox/               # VM provisioning configs
├── ansible/
│   ├── playbooks/             # Configuration playbooks
│   ├── roles/                 # Ansible roles
│   └── inventory/             # Host inventory
├── docker/
│   ├── compose/               # Docker Compose files
│   └── dockerfiles/           # Custom Dockerfiles
├── monitoring/
│   ├── grafana/               # Dashboards and provisioning
│   └── prometheus/            # Scrape configs and rules
├── wazuh/                     # SIEM configuration
├── scripts/
│   ├── bash/                  # Linux automation
│   ├── powershell/            # Windows automation
│   └── python/                # Python utilities
├── ci-cd/
│   └── .github/workflows/     # GitHub Actions pipelines
└── diagrams/                  # Network and architecture diagrams
```

## Setup Phases

| Phase | Description                                      | Status |
|-------|--------------------------------------------------|--------|
| 1     | Proxmox VE installation + VM creation            | [x]    |
| 2     | Windows Server 2025 — AD, DNS, DHCP, GPO         | [x]    |
| 3     | Rocky Linux 10 — base config, Docker             | [x]    |
| 4     | Ansible — automated configuration of all hosts   | [x]    |
| 5     | Terraform — infrastructure as code for Proxmox   | [x]    |
| 6     | Monitoring — Grafana + Prometheus stack           | [x]    |
| 7     | Security — Wazuh SIEM deployment                 | [x]    |
| 8     | CI/CD — GitHub Actions pipelines                 | [x]    |
| 9     | ServiceNow — ticketing integration               | [x]    |
| 10    | Documentation, diagrams, and final polish         | [x]    |

## Getting Started

See [docs/setup-guides/01-proxmox-setup.md](docs/setup-guides/01-proxmox-setup.md) to begin with Phase 1.

## Skills Demonstrated

- Hypervisor management and nested virtualization
- Windows Server administration (AD DS, DNS, DHCP, Group Policy)
- Linux system administration (RHEL-family)
- Container orchestration with Docker
- Infrastructure as Code (Terraform)
- Configuration management (Ansible)
- Monitoring and observability (Grafana/Prometheus)
- Security information and event management (Wazuh)
- Scripting and automation (Bash, PowerShell, Python)
- CI/CD pipeline design (GitHub Actions)
- IT service management (ServiceNow)
- Technical documentation and diagramming
- Networking fundamentals (subnetting, DNS, DHCP, firewalls)
