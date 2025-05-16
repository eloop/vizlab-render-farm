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
  default     = "hq-server"
  description = "The name of the output image"
}

variable "houdini_software_path" {
  type        = string
  default     = "/home/drw900/Downloads/HOUDINI/houdini-20.5.584-linux_x86_64_gcc11.2.tar.gz"
  description = "Path to the Houdini software package"
}

variable "base_image_id" {
  type        = string
  description = "The ID of the base image to use"
  default     = "a281b35e-fb23-44a3-930f-1236bb4a4a72"  # Default to current base image
}

variable "flavor" {
  type        = string
  default     = "c3pl.16c32m20d"
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

variable "ssh_bastion_host" {
  type        = string
  default     = "130.56.246.26"
  description = "The bastion host for SSH access"
}

variable "ssh_bastion_username" {
  type        = string
  default     = "centos"
  description = "The username for the bastion host"
}

variable "ssh_bastion_private_key_file" {
  type        = string
  default     = "~/.ssh/z03.pem"
  description = "Path to the private key file for the bastion host"
}

variable "license_server" {
  type        = string
  default     = "130.56.246.41"
  description = "The Houdini license server address"
}

variable "eula_date" {
  type        = string
  default     = "2021-10-13"
  description = "The EULA acceptance date"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.image_name}-${local.timestamp}"
}

# OpenStack source configuration
source "openstack" "server" {
  image_name                   = local.image_name
  flavor                       = var.flavor
  source_image                 = var.base_image_id
  ssh_username                 = var.ssh_username
  ssh_keypair_name            = var.ssh_keypair_name
  ssh_private_key_file        = var.ssh_private_key_file
  ssh_bastion_host            = var.ssh_bastion_host
  ssh_bastion_username        = var.ssh_bastion_username
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file

  # Security groups
  security_groups             = ["default", "ssh", "ping"]

  # Image metadata
  metadata = {
    build_date    = "{{ timestamp }}"
    os_version    = "24.04"
    os_flavor     = "server"
    builder       = "packer"
    base_image_id = var.base_image_id
    houdini_version = "20.5.584"
  }
}

# Build configuration
build {
  sources = ["source.openstack.server"]

  # Create ramdisk for temporary storage during build
  provisioner "shell" {
    inline = [
      <<EOT
      sudo mkdir -p /mnt/ramdisk
      sudo mount -t tmpfs -o rw,size=16G tmpfs /mnt/ramdisk
      sudo mkdir -p /mnt/ramdisk/ubuntu
      sudo chown ubuntu:ubuntu /mnt/ramdisk/ubuntu
      EOT
    ]
  }

  # Copy required files
  provisioner "file" {
    source      = var.houdini_software_path
    destination = "/mnt/ramdisk/ubuntu/hh.tar.gz"
  }

  provisioner "file" {
    source      = "files/confs"
    destination = "confs"
  }

  # Set up NFS
  provisioner "shell" {
    inline = [
      <<EOT
      sudo apt-get -y install nfs-common
      sudo mkdir -p /g/data/z03
      sudo -- sh -c 'echo gdata1a.cloud.nci.org.au:/mnt/gdata1a/z03    /g/data/z03    nfs    _netdev,auto,hard,intr,timeo=10,retrans=10,vers=4 0 0 >> /etc/fstab'
      EOT
    ]
  }

  # Set up users and groups
  provisioner "shell" {
    inline = [
      <<EOT
      sudo groupadd -g 2202 hqgroup
      sudo useradd  -u 7634  -g hqgroup -s /bin/bash -m drw900
      sudo usermod -aG sudo drw900
      sudo useradd -u 10229 -g hqgroup -s /bin/bash -m hquser
      EOT
    ]
  }

  # Install Houdini
  provisioner "shell" {
    inline = [
      <<EOT
      cd /mnt/ramdisk/ubuntu && sudo tar xvfz ./hh.tar.gz && cd houdini* && sudo ./houdini.install \
        --no-root-check \
        --auto-install \
        --no-install-license \
        --license-server-name ${var.license_server} \
        --accept-EULA ${var.eula_date} \
        --no-install-bin-symlink \
        --no-install-menus \
        --install-sidefxlabs \
        --no-install-hqueue-server \
        --no-install-hqueue-client
      EOT
    ]
  }

  # Install HQueue server
  provisioner "shell" {
    inline = [
      <<EOT
      cd /mnt/ramdisk/ubuntu && cd houdini* && sudo ./houdini.install \
        --no-root-check \
        --auto-install \
        --no-install-license \
        --license-server-name ${var.license_server} \
        --accept-EULA ${var.eula_date} \
        --no-install-houdini \
        --no-install-avahi \
        --no-install-bin-symlink \
        --no-install-menus \
        --no-install-sidefxlabs \
        --install-hqueue-server \
        --hqueue-server-dir /opt/hqueue

      # Create Houdini distribution symlink
      sudo sh -c "cd /opt && mkdir -p houdini_distros && cd houdini_distros && ln -s /opt/hfs20.5 hfs.linux-x86_64"
      EOT
    ]
  }

  # Install HQueue client
  provisioner "shell" {
    inline = [
      <<EOT
      cd /mnt/ramdisk/ubuntu && cd houdini* && sudo ./houdini.install \
        --no-root-check \
        --auto-install \
        --no-install-houdini \
        --no-install-license \
        --license-server-name ${var.license_server} \
        --accept-EULA ${var.eula_date} \
        --no-install-avahi \
        --no-install-bin-symlink \
        --no-install-menus \
        --no-install-sidefxlabs \
        --install-hqueue-client \
        --hqueue-server-name hq-server-internal \
        --hqueue-server-port 5000 \
        --create-hqueue-shared-dir no \
        --mount-hqueue-shared-dir no \
        --hqueue-client-user hquser \
        --hqueue-client-dir /home/hquser/hqclient

      # Disable HQueue client on server
      sudo systemctl stop hqueue-client
      sudo systemctl disable hqueue-client
      EOT
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      <<EOT
      cd $HOME
      rm -r confs
      sudo umount /mnt/ramdisk
      EOT
    ]
  }
}
