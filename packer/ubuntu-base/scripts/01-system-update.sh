#!/bin/bash
set -e

echo "Setting up noninteractive frontend..."
export DEBIAN_FRONTEND=noninteractive
echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

echo "Waiting for cloud-init to complete..."
cloud-init status --wait

echo "Updating package lists..."
sudo apt-get update -y

echo "Upgrading system packages..."
sudo apt-get upgrade -y

echo "System update completed successfully."