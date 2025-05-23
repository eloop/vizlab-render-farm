#!/bin/bash

# Exit on any error
set -e

# Get the directory containing this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Change to project root directory
cd "$PROJECT_ROOT"

echo "Building all images..."

# Build base image first
"$SCRIPT_DIR/build_ubuntu.sh"

# Build server and worker images in parallel
"$SCRIPT_DIR/build_server.sh" &
"$SCRIPT_DIR/build_worker.sh" &

# Wait for all background jobs to complete
wait

echo "All images built!"