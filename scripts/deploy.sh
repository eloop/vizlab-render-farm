#!/bin/bash

# Exit on any error
set -e

# Get the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "Setting up deployment..."

# Create necessary directories
mkdir -p logs confs/hqserver confs/hmqserver

# Generate hosts file
echo "Generating hosts file..."
pip install python-hcl2 --quiet
python3 scripts/genhosts.py

# Make sure mqstart.sh is executable
chmod +x confs/hmqserver/mqstart.sh

# Get latest image information
echo "Finding latest images..."
chmod +x "$SCRIPT_DIR/get_latest_images.py"
eval $("$SCRIPT_DIR/get_latest_images.py")

echo "Using server image: $SERVER_IMAGE_NAME ($SERVER_IMAGE_ID)"
echo "Using worker image: $WORKER_IMAGE_NAME ($WORKER_IMAGE_ID)"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Deploy the infrastructure
echo "Deploying infrastructure..."
terraform apply -auto-approve \
  -var="server_image_id=$SERVER_IMAGE_ID" \
  -var="worker_image_id=$WORKER_IMAGE_ID"

echo "Deployment complete!"