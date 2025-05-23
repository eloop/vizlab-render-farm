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

def delete_image(image_id, image_name):
    """Delete an OpenStack image"""
    print(f"Deleting image {image_name} ({image_id})")
    cmd = ["openstack", "image", "delete", image_id]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Failed to delete image {image_name}: {result.stderr}", file=sys.stderr)
        return False
    return True

def cleanup_images(images, prefix, keep_count=2):
    """Find images with prefix and delete all but the N most recent ones"""
    matching_images = [
        img for img in images
        if img['Name'].startswith(prefix) and img['Status'] == 'active'
    ]

    if not matching_images:
        print(f"No images found with prefix {prefix}")
        return

    # Sort by name in reverse order (newest first due to timestamp in name)
    matching_images.sort(key=lambda x: x['Name'], reverse=True)

    print(f"\nFound {len(matching_images)} images with prefix {prefix}")
    print("Keeping:")
    for img in matching_images[:keep_count]:
        print(f"  {img['Name']}")

    if len(matching_images) > keep_count:
        print("\nDeleting:")
        for img in matching_images[keep_count:]:
            print(f"  {img['Name']}")
            delete_image(img['ID'], img['Name'])
    else:
        print(f"\nNo images to delete for prefix {prefix}")

def main():
    print("Fetching OpenStack images...")
    images = get_openstack_images()

    # Clean up server images
    cleanup_images(images, "hq-server")

    # Clean up worker images
    cleanup_images(images, "hq-worker")

    # Clean up base images
    cleanup_images(images, "ubuntu-base")

if __name__ == "__main__":
    main()