# -*- terraform -*-
#
# Generate the hosts file based on actual n_workers value
#

locals {
  # Generate the hosts file content
  hosts_content = join("\n", concat([
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
    ""
  ],
  # Worker entries
  [for i in range(1, var.n_workers + 1) :
    "${var.cluster_subnet}.${i} hq-worker-${format("%03d", i)} hq-worker-${format("%03d", i)}-internal"
  ]))
}

# Create the hosts file
resource "local_file" "hosts" {
  filename = "${path.module}/confs/hosts"
  content  = local.hosts_content

  # Ensure the confs directory exists
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/confs"
  }
}