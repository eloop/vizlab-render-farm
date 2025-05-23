#!/bin/bash

# Exit on any error
set -e

# Get the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root directory
cd "$PROJECT_ROOT"

# Function to strip ANSI escape sequences
strip_ansi() {
    # Remove color codes and other ANSI escape sequences
    sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"
}

echo "Setting up deployment..."

# Change to terraform directory
cd terraform

# Create necessary directories
mkdir -p confs/hqserver confs/hmqserver

# Make sure mqstart.sh is executable
chmod +x confs/hmqserver/mqstart.sh

# Get latest image information
echo "Finding latest images..."
chmod +x "$SCRIPT_DIR/get_latest_images.py"
eval $("$SCRIPT_DIR/get_latest_images.py")

echo "Using server image: $SERVER_IMAGE_NAME ($SERVER_IMAGE_ID)"
echo "Using worker image: $WORKER_IMAGE_NAME ($WORKER_IMAGE_ID)"

# Initialize Terraform and update providers if needed
#echo "Initializing Terraform..."
#terraform init -upgrade | strip_ansi

# Deploy the infrastructure
echo "Deploying infrastructure..."
# Use tee to both display and save the output, while stripping ANSI codes
terraform apply -auto-approve \
  -var="server_image_id=$SERVER_IMAGE_ID" \
  -var="worker_image_id=$WORKER_IMAGE_ID" 2>&1 | strip_ansi | tee ../logs/deploy.log

echo "Deployment complete!"