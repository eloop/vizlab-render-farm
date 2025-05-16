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

variable "vizfs_ip" {
  type = string
  default = "10.0.0.20"
}
