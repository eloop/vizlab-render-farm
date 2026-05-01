# -*- terraform -*-
#
# Basic setup and provider configuration
#
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.49.0"
    }
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.13.5"
    }
  }
  required_version = ">= 1.3.4"
}

# dw900 turns out we did't need this if we've setup the ENV vars properly...
# provider "openstack" {
#   user_name        = var.username
#   password         = var.password
#   tenant_name      = var.tenant
#   auth_url         = "https://cloud-test.nci.org.au:5000"
#   region           = "CloudV3_test"
#   domain_name      = "NCI"
#   user_domain_name = "NCI"
# }

provider "tailscale" {
  api_key = "${var.tailscale_api_key}"
  tailnet = "drew.whitehouse@gmail.com"
}

# A group so we can enforce antiaffinity
resource "openstack_compute_servergroup_v2" "hq-server-group" {
  name     = "hq-server-group"
  #policies = ["anti-affinity"]
  policies = ["affinity"]
}



locals {

  hosts_path = "${path.module}/confs/hosts"

  # Generate the hosts file content
  hosts_body = join("\n", concat([
    "127.0.0.1 localhost",
    "127.0.1.1 ubuntu",
    "",
    "# The following lines are desirable for IPv6 capable hosts",
    "::1     ip6-localhost ip6-loopback",
    "fe00::0 ip6-localnet",
    "ff00::0 ip6-mcastprefix",
    "ff02::1 ip6-allnodes",
    "ff02::2 ip6-allrouters",
    "",
    # Server entry
    "${var.cluster_subnet}.253 hq-server hq-server-internal",
    "130.56.246.16 newlicenses",
    ""
  ],
  # Worker entries, autgenerated.
  [for i in range(1, var.n_workers + 1) :
    "${var.cluster_subnet}.${i} hq-worker-${format("%03d", i)} hq-worker-${format("%03d", i)}-internal"
  ],
    [""]))

  hosts_md5 = md5(local.hosts_body)

}

resource "local_file" "hosts" {

  filename = local.hosts_path
  content  = local.hosts_body

  # Ensure the confs directory exists
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/confs"
  }
}
