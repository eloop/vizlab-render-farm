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
libc6 libcups2 libcurl4 libdbus-1-3 libdrm2 libegl1 libexpat1 libfontconfig1 libgcc-s1 libgl1 libglib2.0-0 libglu1-mesa libglx0 libice6 libncursesw6 libnspr4 libnss3 libopengl0 libpci3 libsm6 libxcb-cursor0 \
    libglu1 \
    libsm6 \
    bc \
    ffmpeg \
    imagemagick

    # old
    # libglu1 \
    # libsm6 \
    # bc \
    # libnss3 \
    # libxcomposite1 \
    # libxrender1 \
    # libxrandr2 \
    # libfontconfig1 \
    # libxcursor1 \
    # libxi6 \
    # libxtst6 \
    # libxkbcommon0 \
    # libxss1 \
    # libpci3 \

echo "Utility installation completed successfully."
