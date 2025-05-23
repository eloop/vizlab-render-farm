#!/bin/bash

# Exit on any error
set -e

# Get the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "Rebuilding everything..."

# Ensure logs directory exists
mkdir -p logs

# Build all images
"$SCRIPT_DIR/build_all_images.sh"

# Destroy existing infrastructure
"$SCRIPT_DIR/destroy.sh"

# Deploy new infrastructure
"$SCRIPT_DIR/deploy.sh"

echo "Complete! Check logs/ directory for build and deployment logs."