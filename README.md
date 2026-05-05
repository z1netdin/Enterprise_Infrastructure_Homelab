# Enterprise Infrastructure Home Lab

## Why I Built This

I saw a job posting for a Lab/System Administration Intern at ASRC Federal. The role required hands-on experience with Active Directory, Linux, virtualization, monitoring, and automation tools. I didn't get the position, but I used the job description as a blueprint to build this entire lab from scratch so I could actually learn how these tools work together in a real enterprise environment.

This project is my way of turning a missed opportunity into real experience.

## What This Project Is

A home lab running on my personal workstation that simulates an enterprise IT environment. Everything is configured and working together — not just installed, but actually connected and functional.

## What's Running

```
VMware Workstation (on Windows 11)
  |
  |-- Proxmox VE 9.1         Hypervisor (learning the web UI and management)
  |-- Windows Server 2025    Active Directory, DNS, DHCP, Group Policy
  |-- Rocky Linux 10         Docker containers running:
       |-- Nginx              Web server
       |-- Grafana            Monitoring dashboards (port 3000)
       |-- Prometheus         Metrics collection (port 9091)
       |-- Node Exporter      System metrics
       |-- Wazuh Manager      SIEM - security event monitoring
       |-- Wazuh Indexer      SIEM - log storage
       |-- Wazuh Dashboard    SIEM - security dashboard (port 443)
```

## Screenshots

| Proxmox Dashboard | Grafana Monitoring |
|---|---|
| ![Proxmox](docs/screenshots/proxmox_dashboard.png) | ![Grafana](docs/screenshots/Grafana_dashboard.png) |

| Wazuh SIEM | ServiceNow Ticketing |
|---|---|
| ![Wazuh](docs/screenshots/Wazuh_dashboard.png) | ![ServiceNow](docs/screenshots/servicenow_dashboard.png) |

## Tools Used

| Tool | What I Used It For |
|---|---|
| Proxmox VE | Learned hypervisor management and web UI |
| Windows Server 2025 | Set up Active Directory domain, DNS, DHCP, Group Policy |
| Rocky Linux 10 | Linux server admin, package management, firewall config |
| Docker | Deployed Nginx, Grafana, Prometheus, and Wazuh as containers |
| Ansible | Automated Rocky Linux configuration (packages, firewall, services) |
| Terraform | Wrote infrastructure-as-code configs for Proxmox VM provisioning |
| Grafana + Prometheus | Built monitoring dashboards showing CPU, RAM, disk, network |
| Wazuh | Deployed a SIEM for security monitoring and threat detection |
| GitHub Actions | CI/CD pipelines that lint Ansible playbooks and validate Docker configs |
| ServiceNow | Created incidents and learned IT ticketing workflows |
| PowerShell | Automated Hyper-V VM creation and Windows configuration |
| Bash | Proxmox post-install setup and Linux automation |
| Python | ServiceNow REST API integration script |

## Project Structure

```
.
├── ansible/              # Ansible config and playbooks
│   ├── playbooks/        #   Server configuration automation
│   └── inventory/        #   Host inventory
├── docker/compose/       # Docker Compose files for monitoring and SIEM
├── monitoring/prometheus/ # Prometheus scrape configuration
├── terraform/proxmox/    # Terraform configs for VM provisioning
├── scripts/
│   ├── bash/             # Linux automation scripts
│   ├── powershell/       # Windows/Hyper-V automation scripts
│   └── python/           # ServiceNow API integration
├── docs/
│   ├── setup-guides/     # Step-by-step setup documentation
│   └── screenshots/      # Configuration screenshots
├── diagrams/             # Network architecture diagrams
└── .github/workflows/    # CI/CD pipeline definitions
```

## What I Learned

- How Active Directory, DNS, and DHCP work together in a Windows domain
- Linux server administration on a RHEL-based distro (Rocky Linux)
- Deploying and managing multi-container applications with Docker Compose
- Writing Ansible playbooks to automate server configuration
- Setting up monitoring with Grafana and Prometheus
- Deploying a SIEM (Wazuh) for security event monitoring
- CI/CD pipelines with GitHub Actions
- IT service management workflows with ServiceNow
- Networking fundamentals: subnetting, DNS resolution, DHCP scopes, firewall rules
- The importance of documentation and version control in IT operations

## Setup Guide

See [docs/setup-guides/01-proxmox-setup.md](docs/setup-guides/01-proxmox-setup.md) for detailed setup instructions.
