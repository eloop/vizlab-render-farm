packer {
  required_plugins {
    openstack = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

# Variables for better flexibility and reuse
variable "image_name" {
  type        = string
  default     = "ubuntu-24.04-base"
  description = "The name of the output image"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.image_name}-${local.timestamp}"
}

variable "source_image_id" {
  type        = string
  default     = "2739e944-abd1-42e7-a0e3-929b221c002f"  # Ubuntu Noble Server 2024-10-04
  description = "The source image ID to build from"
}

variable "flavor" {
  type        = string
  default     = "c3.2c4m10d"
  description = "The flavor to use for building the image"
}

variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "The SSH username for connecting to the instance"
}

variable "ssh_keypair_name" {
  type        = string
  default     = "z03"
  description = "The name of the SSH keypair to use"
}

variable "ssh_private_key_file" {
  type        = string
  default     = "~/.ssh/z03.pem"
  description = "Path to the SSH private key file"
}

# OpenStack source configuration
source "openstack" "ubuntu" {
  image_name           = local.image_name
  flavor              = var.flavor
  source_image        = var.source_image_id
  ssh_username        = var.ssh_username
  ssh_keypair_name    = var.ssh_keypair_name
  ssh_private_key_file = var.ssh_private_key_file

  # Security groups
  security_groups     = ["default", "ssh", "ping"]

  # Image metadata
  metadata = {
    build_date    = "{{ timestamp }}"
    os_version    = "24.04"
    os_flavor     = "server"
    builder       = "packer"
    base_image_id = var.source_image_id
  }
}

# Build configuration
build {
  sources = ["source.openstack.ubuntu"]

  # System update and base packages
  provisioner "shell" {
    script = "scripts/01-system-update.sh"
  }

  # Install common utilities
  provisioner "shell" {
    script = "scripts/02-install-utilities.sh"
  }

  # Clean up
  provisioner "shell" {
    script = "scripts/99-cleanup.sh"
  }
}