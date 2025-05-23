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

provider "openstack" {
  user_name        = var.username
  password         = var.password
  tenant_name      = var.tenant
  auth_url         = "https://cloud.nci.org.au:5000/v3"
  region           = "CloudV3"
  domain_name      = "NCI"
  user_domain_name = "NCI"
}

provider "tailscale" {
  api_key = "${var.tailscale_api_key}"
  tailnet = "drew.whitehouse@gmail.com"
}

# A group so we can enforce antiaffinity
resource "openstack_compute_servergroup_v2" "hq-server-group" {
  name     = "hq-server-group"
  policies = ["anti-affinity"]
}
