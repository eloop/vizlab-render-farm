#!/bin/bash
set -e

# Get the latest base image ID using grep
LATEST_BASE_ID=$(openstack image list --sort created_at:desc | grep "ubuntu-24.04-base-" | head -n 1 | awk '{print $2}')

if [ -z "$LATEST_BASE_ID" ]; then
    echo "Error: No base image found matching pattern 'ubuntu-24.04-base-'"
    exit 1
fi

# Output the ID in a format Packer can use
echo "$LATEST_BASE_ID"