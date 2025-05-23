datacenter = "dc1"
client {
  enabled = true
  # server_join {
  #   retry_join = ["10.0.6.255", "10.0.6.240", "10.0.6.241"]
  #   retry_interval = "30s"
  # }

  # not sure how this will work with openstack floating_ips??
  host_network "localhost" {
    cidr = "0.0.0.0/0"
    interface="lo"
  }
  host_network "public" {
    cidr = "0.0.0.0/0"
    interface="ens3"
  }
  host_network "tailscale" {
    cidr = "0.0.0.0/0"
    interface="tailscale0"
  }
  host_volume "gdata" {
    enabled = true
    path = "/g/data/z03"
  }
  #host_volume "data" {
  #  enabled = true
  #  path = "/data"
  #}
}

# note this is not very secure! Better to just use public image repo
# for the time being. Maybe Vault is the solution to this?
plugin "docker" {
  config {
    auth {
#      config = "/root/.docker/config.json"
    }
  }
}
