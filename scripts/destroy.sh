#!/bin/bash

# Exit on any error
set -e

# Get the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "WARNING: This will destroy all resources in the current deployment!"
echo "You have 5 seconds to press Ctrl+C to abort..."
sleep 5

# Get latest image information
echo "Finding latest images..."
chmod +x "$SCRIPT_DIR/get_latest_images.py"
eval $("$SCRIPT_DIR/get_latest_images.py")

echo "Using server image: $SERVER_IMAGE_NAME ($SERVER_IMAGE_ID)"
echo "Using worker image: $WORKER_IMAGE_NAME ($WORKER_IMAGE_ID)"

# Change to terraform directory
cd terraform

# Destroy the infrastructure
echo "Destroying infrastructure..."
terraform destroy -auto-approve \
  -var="server_image_id=$SERVER_IMAGE_ID" \
  -var="worker_image_id=$WORKER_IMAGE_ID"

echo "Cleanup complete!"
