# Enterprise Infrastructure Home Lab

## About

I saw a job posting for a Lab/System Admin Intern role at ASRC Federal. The description listed tools like Active Directory, Linux, Docker, Ansible, and monitoring. I wanted to learn how all of these actually work together, so I built this lab from scratch on my own machine.

## What's in the Lab

All running on VMware Workstation on my Windows 11 PC:

- **Proxmox VE 9.1** - hypervisor management
- **Windows Server 2025** - Active Directory, DNS, DHCP, Group Policy
- **Rocky Linux 10** - Docker host running 7 containers:
  - Nginx (web server)
  - Grafana (monitoring dashboards)
  - Prometheus (metrics collection)
  - Node Exporter (system metrics)
  - Wazuh Manager, Indexer, Dashboard (SIEM)

## Screenshots

### Proxmox Dashboard
![Proxmox](docs/screenshots/proxmox-dashboard.png)

### Grafana Monitoring
![Grafana](docs/screenshots/grafana-dashboard.png)

### Wazuh SIEM
![Wazuh](docs/screenshots/wazuh-dashboard.png)

### Active Directory, DNS, DHCP, GPO
![AD](docs/screenshots/ad-dhcp-gpo.png)

### Ansible Automation
![Ansible](docs/screenshots/ansible-playbook.png)

### ServiceNow Incident
![ServiceNow](docs/screenshots/servicenow-incident.png)

## Tools

| Tool | What I did with it |
|---|---|
| Proxmox VE | Installed and managed the hypervisor web UI |
| Windows Server 2025 | Set up AD domain, DNS, DHCP, Group Policy |
| Rocky Linux 10 | Server admin, packages, firewall |
| Docker | Ran Nginx, Grafana, Prometheus, Wazuh as containers |
| Ansible | Automated server setup (packages, firewall, services) |
| Terraform | Wrote IaC configs for Proxmox VM provisioning |
| Grafana + Prometheus | Monitoring dashboards for CPU, RAM, disk, network |
| Wazuh | Security monitoring and threat detection |
| GitHub Actions | CI/CD that lints Ansible and validates Docker configs |
| ServiceNow | Created incidents, learned ticketing workflows |
| PowerShell | Automated VM creation |
| Bash | Linux automation scripts |
| Python | ServiceNow REST API integration |

## Project Structure

```
ansible/           Ansible playbooks and inventory
docker/compose/    Docker Compose files
monitoring/        Prometheus config
terraform/proxmox/ Terraform VM configs
scripts/bash/      Linux scripts
scripts/powershell/ Windows scripts
scripts/python/    Python scripts
docs/screenshots/  Screenshots
diagrams/          Network diagrams
.github/workflows/ CI/CD pipelines
```

## What I Learned

- How AD, DNS, and DHCP work together in a domain
- Linux server admin on Rocky Linux (RHEL-based)
- Deploying containers with Docker Compose
- Writing Ansible playbooks for automation
- Monitoring with Grafana and Prometheus
- Security monitoring with Wazuh SIEM
- CI/CD with GitHub Actions
- IT ticketing with ServiceNow
- Networking: subnetting, DNS, DHCP, firewall rules
