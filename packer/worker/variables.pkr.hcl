# NOTE: "bastion" is a small Centos node that has to be manually created
# via the dashboard. It will then be used for all connections into the
# cluster. This must be done before using Terraform.  also note that
# we set 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf' on that
# node. We could make it here, but it's a pain to wait for it every time
# we do a complete "destroy/apply" cycle.

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

# Variables for better flexibility and reuse
variable "image_name" {
  type        = string
  default     = "hq-worker"
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

variable "vizfs_ip" {
  type        = string
  default     = "10.0.0.20"
  description = "The IP address of the VizFS server"
}

# "dev"|"prod"|"testing" etc
variable "devtag" {
  type = string
  default = "dev"
}

# How many slurm/hqueue workers will we create?
variable "n_workers" {
  type    = number
  default = 2
}

# This is the slurm controller as well as the Hqueue server.
variable "headnode_ip" {
  type = string
  default = "130.56.246.40"
}

# tailscale key for the headnode
variable "tailscale_key" {
  type = string
  default = "tskey-auth-kjGd1n2CNTRL-kzTFCNvrMahhQbFCNvrMahqBUBEp8aiqX"
}
variable "tailscale_api_key" {
  type = string
  default = "tskey-api-k2HdG33CNTRL-DXsWCfhjzcKSa5XCfhjzcKQUmVtUChcSH"
}

variable "bastion_ip" {
  type = string
  default = "130.56.246.26"
}