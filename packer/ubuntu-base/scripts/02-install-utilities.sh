#!/bin/bash
set -e

# Set noninteractive frontend
export DEBIAN_FRONTEND=noninteractive

echo "Installing common system utilities..."
sudo apt-get install -y \
    tree \
    emacs-nox \
    btop \
    htop \
    cmake \
    git \
    wget \
    kitty-terminfo \
    jq \
    apt-utils \
    python3 \
    python3-pip \
    curl \
    unzip

echo "Installing Houdini dependencies..."
sudo apt-get install -y \
    libglu1 \
    libsm6 \
    bc \
    libnss3 \
    libxcomposite1 \
    libxrender1 \
    libxrandr2 \
    libfontconfig1 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libxkbcommon0 \
    libxss1 \
    libpci3 \
    ffmpeg \
    imagemagick

echo "Utility installation completed successfully."