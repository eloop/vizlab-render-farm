# vizlab-render-farm

A Terraform and Packer-based deployment system for creating a Houdini render farm on OpenStack. This project automates the deployment of a server node and multiple worker nodes, configured for distributed rendering with Houdini's HQueue system.

## Prerequisites

- OpenStack CLI and credentials (source `z03-openrc-v3.sh`)
- Terraform (>= 1.3.4)
- Packer (>= 1.1.0)
- Python 3 with `python-hcl2` package
- SSH key pair (default: `z03` keypair, `~/.ssh/z03.pem`)
- Houdini software package (commercial license required, default: 21.0.671)
- Tailscale account with auth key and API key (for VPN access)

## Project Structure

```
vizlab-render-farm/
├── setup.sh                  # Source OpenStack credentials and set Terraform/Packer env vars
├── set_image_envars.sh       # Get latest images and set Terraform image ID variables
├── z03-openrc.sh             # OpenStack credentials template (gitignored)
├── z03-openrc-v3.sh          # OpenStack v3 credentials template (gitignored)
├── packer/                   # Packer configurations for building images
│   ├── ubuntu-base/          # Base Ubuntu 24.04 image setup
│   │   └── ubuntu-24-04.pkr.hcl
│   ├── server/               # Server node image configuration
│   │   ├── server.pkr.hcl
│   │   ├── variables.pkr.hcl
│   │   └── files/confs/      # Config files (HQueue, Consul, Nomad, Docker)
│   └── worker/               # Worker node image configuration
│       ├── worker.pkr.hcl
│       ├── variables.pkr.hcl
│       └── files/confs/
├── terraform/                # Terraform configurations
│   ├── confs/               # Configuration files for nodes
│   │   ├── hosts            # Generated hosts file
│   │   ├── hqserver/        # HQueue server config (hqserver.ini)
│   │   └── hmqserver/       # Message queue server config
│   ├── main.tf              # Provider config, hosts file generation
│   ├── server.tf            # Server node configuration
│   ├── workers.tf           # Worker nodes configuration
│   ├── networking.tf        # Security groups and firewall rules
│   ├── hosts.tf             # Hosts file generation
│   └── variables.tf         # Variable definitions
└── scripts/                  # Utility scripts
    ├── build_all_images.sh   # Build all images (base, server, worker)
    ├── build_ubuntu.sh       # Build base Ubuntu 24.04 image
    ├── build_server.sh       # Build server image only
    ├── build_worker.sh       # Build worker image only
    ├── deploy.sh             # Deploy infrastructure with Terraform
    ├── destroy.sh            # Tear down infrastructure
    ├── destroy_workers.sh    # Destroy only worker nodes
    ├── rebuild_everything.sh # Full rebuild (images + deploy)
    ├── get_latest_images.py  # Find latest OpenStack images
    ├── cleanup_old_images.py # Remove old images (keeps 2 latest)
    └── genhosts.py           # Generate hosts file from variables.tf
```

## Quick Start

1. Source the environment setup script:
   ```bash
   source setup.sh
   ```

2. Get the latest images and set Terraform variables:
   ```bash
   source set_image_envars.sh
   ```

3. Build the images:
   ```bash
   ./scripts/build_all_images.sh
   ```
   This will create the base Ubuntu 24.04 image, then the server and worker node images in OpenStack.

4. Deploy the infrastructure:
   ```bash
   ./scripts/deploy.sh
   ```
   This will:
   - Generate the hosts file
   - Configure networking
   - Deploy the server node
   - Deploy the worker nodes (default: 30)
   - Configure HQueue
   - Set up Tailscale subnet routing for VPN access

## Configuration

### Key Variables (in `terraform/variables.tf`)

- `n_workers`: Number of worker nodes (default: **30**)
- `cluster_subnet`: Internal network subnet (default: `10.0.7`)
- `server_flavor`: OpenStack flavor for server (default: `c3ep.4c8m20d`)
- `worker_flavor`: OpenStack flavor for workers (default: `c3ep.16c32m20d`)
- `license_server`: Houdini license server IP (default: `10.0.1.216`)
- `vizfs_ip`: VizFS shared storage server IP (default: `10.150.0.20`)
- `headnode_ip`: HQueue server floating IP (default: `130.56.246.40`)
- `tailscale_auth_key`: Tailscale auth key for VPN access
- `tailscale_api_key`: Tailscale API key for managing devices

### Packer Variables (in `packer/server/variables.pkr.hcl` and `packer/worker/variables.pkr.hcl`)

- `houdini_software_path`: Path to Houdini package (default: `houdini-21.0.671-linux_x86_64_gcc11.2.tar.gz`)
- `base_image_id`: Base Ubuntu image ID
- `flavor`: OpenStack flavor for building images (default: `c3ep.8c16m20d`)
- `ssh_keypair_name`: SSH keypair name (default: `z03`)
- `license_server`: Houdini license server (default: `10.0.1.216`)
- `eula_date`: Houdini EULA acceptance date (default: `2021-10-13`)

### Example: Change Number of Workers

Edit `terraform/variables.tf`:
```hcl
variable "n_workers" {
  type    = number
  default = 30  # Change this to desired number of workers
}
```

## Management Scripts

### Image Management
- `scripts/build_all_images.sh`: Build all images (base Ubuntu, server, worker)
- `scripts/build_ubuntu.sh`: Build base Ubuntu 24.04 image only
- `scripts/build_server.sh`: Build server image only
- `scripts/build_worker.sh`: Build worker image only
- `scripts/get_latest_images.py`: Get latest OpenStack image information
- `scripts/cleanup_old_images.py`: Clean up old OpenStack images (keeps 2 latest)

### Infrastructure Management
- `scripts/deploy.sh`: Deploy the entire infrastructure with Terraform
- `scripts/destroy.sh`: Tear down the entire infrastructure
- `scripts/destroy_workers.sh`: Destroy only worker nodes (preserves server)
- `scripts/rebuild_everything.sh`: Full rebuild (images + deploy)

### Utilities
- `scripts/genhosts.py`: Generate hosts file from `terraform/variables.tf`
- `setup.sh`: Source OpenStack credentials and export Terraform/Packer variables
- `set_image_envars.sh`: Get latest images and set Terraform image ID variables

## Maintenance

- The server node is assigned a floating IP (`130.56.246.40`) for external access
- Worker nodes are only accessible within the internal network (`10.0.7.x`)
- **Tailscale VPN**: The project uses Tailscale subnet routing for VPN access, eliminating the need for a separate bastion host
  - Tailscale auth key is configured in `terraform/variables.tf`
  - The server node acts as a Tailscale subnet router
- Configuration changes to workers (e.g., hosts file updates) are automatically propagated when changing `n_workers`
- Base images use Ubuntu 24.04 with Houdini 21.0.671 pre-installed
- Shared storage is provided via VizFS at `10.150.0.20`

## Troubleshooting

1. If deployment fails with SSH errors:
   - Check your SSH key configuration (`~/.ssh/z03.pem`)
   - Ensure security groups allow necessary access
   - Verify OpenStack credentials are sourced (`source setup.sh`)

2. If HQueue isn't connecting:
   - Verify the hosts file is correctly generated in `terraform/confs/hosts`
   - Check network connectivity between nodes
   - Ensure HQueue services are running on both server and workers
   - Verify Tailscale connection if accessing from outside the network

3. If images fail to build:
   - Verify Houdini software package path in Packer variables
   - Check base image ID is valid
   - Ensure OpenStack flavor is available

## Contributing

Feel free to submit issues and pull requests for improvements.
