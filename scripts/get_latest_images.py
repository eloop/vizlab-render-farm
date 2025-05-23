#!/usr/bin/env python3
import json
import subprocess
from datetime import datetime
import sys
import os
from pathlib import Path

# Get the directory containing this script
SCRIPT_DIR = Path(os.path.dirname(os.path.abspath(__file__)))
PROJECT_ROOT = SCRIPT_DIR.parent

def get_openstack_images():
    """Get all images from OpenStack"""
    cmd = ["openstack", "image", "list", "--format", "json", "--long"]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        raise Exception(f"Failed to get images: {result.stderr}")
    return json.loads(result.stdout)

def find_latest_image(images, prefix):
    """Find the latest image with given prefix based on creation date"""
    # Debug output
    print(f"Looking for images with prefix: {prefix}", file=sys.stderr)

    matching_images = [
        img for img in images
        if img['Name'].startswith(prefix) and img['Status'] == 'active'
    ]

    if not matching_images:
        print(f"No images found with prefix {prefix}", file=sys.stderr)
        return None, None

    # Debug: print matching images
    print(f"Found matching images:", file=sys.stderr)
    for img in matching_images:
        print(f"  Name: {img['Name']}", file=sys.stderr)
        for k, v in img.items():
            print(f"    {k}: {v}", file=sys.stderr)

    # Sort by name in reverse order to get the latest timestamp
    matching_images.sort(key=lambda x: x['Name'], reverse=True)
    latest = matching_images[0]
    return latest['ID'], latest['Name']

def main():
    images = get_openstack_images()

    # Find latest server and worker images
    server_id, server_name = find_latest_image(images, "hq-server")
    worker_id, worker_name = find_latest_image(images, "hq-worker")

    # Output in format that can be easily parsed by shell script
    if server_id:
        print(f"SERVER_IMAGE_ID={server_id}")
        print(f"SERVER_IMAGE_NAME={server_name}")
    if worker_id:
        print(f"WORKER_IMAGE_ID={worker_id}")
        print(f"WORKER_IMAGE_NAME={worker_name}")

if __name__ == "__main__":
    main()
