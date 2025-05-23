# vizlab-render-farm

A Terraform and Packer-based deployment system for creating a Houdini render farm on OpenStack. This project automates the deployment of a server node and multiple worker nodes, configured for distributed rendering with Houdini's HQueue system.

## Prerequisites

- OpenStack CLI and credentials
- Terraform (>= 1.3.4)
- Packer
- Python 3 with `python-hcl2` package
- SSH key pair for node access
- Houdini software package (commercial license required)

## Project Structure

```
vizlab-render-farm/
├── packer/              # Packer configurations for building images
│   ├── server/         # Server node image configuration
│   └── worker/         # Worker node image configuration
├── terraform/          # Terraform configurations
│   ├── confs/         # Configuration files for nodes
│   ├── main.tf        # Main Terraform configuration
│   ├── server.tf      # Server node configuration
│   ├── workers.tf     # Worker nodes configuration
│   └── variables.tf   # Variable definitions
└── scripts/           # Utility scripts
```

## Quick Start

1. Build the images:
   ```bash
   ./scripts/build_all_images.sh
   ```
   This will create both server and worker node images in OpenStack.

2. Deploy the infrastructure:
   ```bash
   ./scripts/deploy.sh
   ```
   This will:
   - Generate the hosts file
   - Configure networking
   - Deploy the server node
   - Deploy the worker nodes
   - Configure HQueue

## Configuration

1. Set the number of worker nodes in `terraform/variables.tf`:
   ```hcl
   variable "n_workers" {
     default = 2  # Change this to desired number of workers
   }
   ```

2. Adjust node specifications (if needed) in:
   - `terraform/server.tf` for the server node
   - `terraform/workers.tf` for worker nodes

## Management Scripts

- `scripts/deploy.sh`: Deploy the entire infrastructure
- `scripts/destroy.sh`: Tear down the infrastructure
- `scripts/rebuild_everything.sh`: Rebuild images and redeploy
- `scripts/cleanup_old_images.py`: Clean up old OpenStack images
- `scripts/get_latest_images.py`: Get latest image information

## Maintenance

- The server node is assigned a floating IP for external access
- Worker nodes are only accessible within the internal network
- Configuration changes to workers (e.g., hosts file updates) are automatically propagated when changing `n_workers`

## Troubleshooting

1. If deployment fails with SSH errors:
   - Check your SSH key configuration
   - Ensure security groups allow necessary access

2. If HQueue isn't connecting:
   - Verify the hosts file is correctly generated
   - Check network connectivity between nodes
   - Ensure HQueue services are running on both server and workers

## Contributing

Feel free to submit issues and pull requests for improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
