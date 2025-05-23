# NOTE: "bastion" is a small Centos node that has to be manually created
# via the dashboard. It will then be used for all connections into the
# cluster. This must be done before using Terraform.  also note that
# we set 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf' on that
# node. We could make it here, but it's a pain to wait for it every time
# we do a complete "destroy/apply" cycle.
#
# update: using Tailscale subnet routing allows us to *not* have to go
# through the bastion these days!

variable "username" {
  description = "openstack username"
  type = string
  sensitive = true
}

variable "password" {
  description = "openstack password"
  type = string
  sensitive = true
}

variable "tenant" {
  description = "openstack tenant"
  type = string
  sensitive = true
}

# "dev"|"prod"|"testing" etc
variable "devtag" {
  type = string
  default = "dev"
}

# How many slurm/hqueue workers will we create?
variable "n_workers" {
  type    = number
  default = 1
}

# If this gets changed, remember to change in confs/genhost.py as well and regenerate.
variable "cluster_subnet" {
  type = string
  default = "10.0.7"
}

# This is the slurm controller as well as the Hqueue server.
variable "headnode_ip" {
  type = string
  default = "130.56.246.40"
}

# SSH Configuration
variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "The SSH username for connecting to instances"
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

# # Bastion Configuration
# variable "bastion_host" {
#   type        = string
#   default     = "130.56.246.26"
#   description = "The bastion host for SSH access"
# }

# variable "bastion_username" {
#   type        = string
#   default     = "centos"
#   description = "The username for the bastion host"
# }

# variable "bastion_private_key_file" {
#   type        = string
#   default     = "~/.ssh/z03.pem"
#   description = "Path to the private key file for the bastion host"
# }

# Houdini Configuration
variable "license_server" {
  type        = string
  default     = "130.56.246.41"
  description = "The Houdini license server address"
}

# Storage Configuration
variable "vizfs_ip" {
  type        = string
  default     = "10.0.0.20"
  description = "The IP address of the VizFS server"
}

# Tailscale Configuration
variable "tailscale_auth_key" {
  type = string
  default = "tskey-auth-kbEDxUByMu11CNTRL-WGfXicmkctKZXnXicmkctKGG6qfhHN5y"
  description = "Tailscale authentication key for the headnode"
}

variable "tailscale_api_key" {
  type = string
  default = "tskey-api-kgsUfnMpE511CNTRL-zubpVf8cDXBMGjpVf8cDXBz3UANA1gVZQ"
  description = "Tailscale API key for managing devices"
}

# Image Configuration
variable "server_image_prefix" {
  type        = string
  default     = "hq-server"
  description = "The prefix for the server image name"
}

variable "worker_image_prefix" {
  type        = string
  default     = "hq-worker"
  description = "The prefix for the worker image name"
}

variable "server_image_id" {
  type        = string
  description = "The ID of the server image to use"
}

variable "worker_image_id" {
  type        = string
  description = "The ID of the worker image to use"
}
