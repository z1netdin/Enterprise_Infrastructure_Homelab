"""
ServiceNow Incident Creator
Creates incidents via the ServiceNow REST API.
Used to demonstrate IT service management integration.
"""

import requests
import json
import os
import sys


def create_incident(instance_url, username, password, short_desc, description, urgency=3):
    """
    Create an incident in ServiceNow.

    Args:
        instance_url: ServiceNow instance (e.g., https://dev12345.service-now.com)
        username: ServiceNow admin username
        password: ServiceNow admin password
        short_desc: Brief incident title
        description: Detailed incident description
        urgency: 1=High, 2=Medium, 3=Low
    """
    url = f"{instance_url}/api/now/table/incident"

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
    }

    payload = {
        "short_description": short_desc,
        "description": description,
        "urgency": str(urgency),
        "assignment_group": "Service Desk",
        "category": "Infrastructure",
    }

    response = requests.post(
        url,
        auth=(username, password),
        headers=headers,
        json=payload,
    )

    if response.status_code == 201:
        result = response.json()["result"]
        print(f"Incident created successfully!")
        print(f"  Number:      {result['number']}")
        print(f"  Sys ID:      {result['sys_id']}")
        print(f"  State:       {result['state']}")
        print(f"  Description: {result['short_description']}")
        return result
    else:
        print(f"Error: {response.status_code}")
        print(response.text)
        return None


if __name__ == "__main__":
    # Configuration - set these environment variables or replace with your values
    INSTANCE = os.getenv("SNOW_INSTANCE", "https://dev12345.service-now.com")
    USERNAME = os.getenv("SNOW_USERNAME", "admin")
    PASSWORD = os.getenv("SNOW_PASSWORD", "password")

    # Example incidents for the lab
    incidents = [
        {
            "short_desc": "Grafana dashboard not loading",
            "description": "The Grafana monitoring dashboard on rocky-web01 (port 3000) is returning a 502 error. Users cannot view system metrics.",
            "urgency": 2,
        },
        {
            "short_desc": "Wazuh agent disconnected on win-dc01",
            "description": "The Wazuh agent on the domain controller (win-dc01) has stopped reporting. Last check-in was 30 minutes ago. Security monitoring is impacted.",
            "urgency": 1,
        },
        {
            "short_desc": "DHCP scope running low on addresses",
            "description": "The DHCP scope on win-dc01 has less than 10% of addresses remaining. New devices may not be able to obtain an IP address.",
            "urgency": 3,
        },
    ]

    print("=" * 50)
    print("ServiceNow Incident Creator")
    print(f"Instance: {INSTANCE}")
    print("=" * 50)

    for incident in incidents:
        print(f"\nCreating: {incident['short_desc']}")
        create_incident(
            INSTANCE,
            USERNAME,
            PASSWORD,
            incident["short_desc"],
            incident["description"],
            incident["urgency"],
        )
