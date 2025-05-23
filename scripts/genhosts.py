#!/usr/bin/env python3
#
# Script for generating hosts file for the cluster
# Reads n_workers from variables.tf
#

import os
import sys
import hcl2  # You'll need to pip install python-hcl2
from pathlib import Path

# Get the directory containing this script
SCRIPT_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = SCRIPT_DIR.parent
TERRAFORM_DIR = PROJECT_ROOT / "terraform"

def get_n_workers():
    """Read the number of workers from variables.tf"""
    with open(TERRAFORM_DIR / 'variables.tf', 'r') as f:
        config = hcl2.load(f)

    # Find the n_workers variable
    for var in config['variable']:
        if 'n_workers' in var:
            return var['n_workers']['default']
    return 2  # Default if not found

subnet = 7  # This matches the cluster_subnet in variables.tf (10.0.7.x)

def generate_hosts(n_workers, cluster_subnet):
    """Generate hosts file content for the cluster"""
    hosts = []

    # Add localhost entries
    hosts.extend([
        "127.0.0.1 localhost",
        "127.0.1.1 ubuntu",
        "",
        "# The following lines are desirable for IPv6 capable hosts",
        "::1     ip6-localhost ip6-loopback",
        "fe00::0 ip6-localnet",
        "ff00::0 ip6-mcastprefix",
        "ff02::1 ip6-allnodes",
        "ff02::2 ip6-allrouters",
        ""
    ])

    # Add server entries
    hosts.extend([
        f"{cluster_subnet}.253 hq-server hq-server-internal",
        ""
    ])

    # Add worker entries
    for i in range(1, n_workers + 1):
        hosts.append(f"{cluster_subnet}.{i} hq-worker-{i:03d} hq-worker-{i:03d}-internal")

    return "\n".join(hosts)

def main():
    n_workers = get_n_workers()

    # Create confs directory if it doesn't exist
    confs_dir = TERRAFORM_DIR / "confs"
    confs_dir.mkdir(exist_ok=True)

    # Generate hosts file content
    hosts_content = generate_hosts(n_workers, f"10.0.{subnet}")

    # Write to file in the confs directory
    hosts_file = confs_dir / "hosts"
    with open(hosts_file, "w") as f:
        f.write(hosts_content)
        f.write("\n")  # Add final newline

    print(f"Generated hosts file for {n_workers} workers")

if __name__ == '__main__':
    main()