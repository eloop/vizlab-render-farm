# -*- terraform -*-
#
# The server node configuration
#

# This node runs the hqserver
resource "openstack_compute_instance_v2" "hq_server" {
  name        = "hq-server"
  image_id    = var.server_image_id
  flavor_name = "c3pl.16c32m20d"

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.hq-server-group.id}"
  }

  key_pair    = "z03"

  # no external ssh at the moment
  security_groups = ["default", "ping",
    "${openstack_networking_secgroup_v2.wideopen_group.name}",
    "${openstack_networking_secgroup_v2.external_group.name}"
  ]

  network {
    uuid        = "9227876a-c00a-4bc7-8cc5-4419b75f5bc5"
    fixed_ip_v4 = "${var.cluster_subnet}.253"
  }

  connection {
    type             = "ssh"
    user             = var.ssh_username
    private_key      = file(var.ssh_private_key_file)
    host             = self.network[0].fixed_ip_v4
    #bastion_user     = var.bastion_username
    #bastion_host     = var.bastion_host
  }

  provisioner "file" {
    source      = "${path.module}/confs"
    destination = "confs"
  }

  # these two are convenient while developing, may remove later
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.name} || true"
  }
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.name}-internal || true"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT

      sudo cp ./confs/hosts /etc/hosts

      # houdini configuration
      sudo cp ./confs/hqserver/hqserver.ini /opt/hqueue
      sudo cp ./confs/hqserver/network_folders.ini /opt/hqueue
      sudo cp ./confs/hqserver/sesi_licenses.pref /home/hquser/.sesi_licenses.pref
      sudo chown hquser:hqgroup /home/hquser/.sesi_licenses.pref

      # restart the houdini stuff, need to put this into something like supervisor of systemd units for reboot.
      #sudo /opt/hqueue/scripts/hqserverd start
      #sudo -u hquser /home/hquser/hqclient/hqclientd start

      # drw900 - H20.5
      # we want to run as hquser, not root so change ownership to make things easy
      #sudo chown -R hquser:hqgroup /opt/hqueue
      #sudo cp ./confs/hqserver/hqserver.service /etc/systemd/system
      #sudo systemctl enable hqserver
      #sudo systemctl start hqserver

      # the PDG message queue service
      sudo cp ./confs/hmqserver/hmqserver.service /etc/systemd/system
      sudo cp ./confs/hmqserver/mqstart.sh /home/hquser/mqstart.sh
      sudo chmod +x /home/hquser/mqstart.sh
      sudo chown hquser:hqgroup /home/hquser/mqstart.sh
      sudo systemctl enable hmqserver
      sudo systemctl start hmqserver

      # we won't do this for the time being, if we want to add it back in you'll need to add
      # the floating ip to the rules so that the client can access mqserver via the hq-server name.
      #sudo cp ./confs/hqclient/hqclient.service /etc/systemd/system
      #sudo systemctl enable hqclient
      #sudo systemctl start hqclient

      # mount the data disk, now done in the image?
      #sudo mkdir -p /data
      #sudo -- sh -c 'echo ${var.vizfs_ip}:/data /data  nfs    _netdev,auto,hard,intr,timeo=10,retrans=10 0 0 >> /etc/fstab'

      echo Done!

      # # cleanup
      # "rm -r confs",
      EOT
      ,
    ]
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT

      # We want to make sure that the Tailscale device has been
      # deleted, so we delete it if it exists.
      # echo Setting up Tailscale

      # NOTE: this next bit has been updated and not tested yet.... (drw900)
      # Tailscale - the package is already installed in the image.
      # delete the old tailscale host for if it exists
      # curl 'https://api.tailscale.com/api/v2/tailnet/drew.whitehouse@gmail.com/devices' -u "${var.tailscale_api_key}:" |  \
      # jq -r '.devices[] | select(.hostname == "${self.name}") | .nodeId' | \
      # while IFS= read -r nodeid; do
      #     echo nodeid = $nodeid
      #     echo curl -x DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${var.tailscale_api_key}:"
      #     curl -X DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${var.tailscale_api_key}:" -v
      # done
      # # I don't want this DNS going through my NextDNS, so no DNS on this one.
      #sudo tailscale up --authkey=${var.tailscale_auth_key} --accept-dns=false --ssh --hostname=hq-server-ts
      EOT
      ,
    ]
  }
}

# Floating IP for the head node.
resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = var.headnode_ip #"130.56.246.40"
  instance_id = openstack_compute_instance_v2.hq_server.id
}

# Commented out old disk configuration code preserved for reference
/*
# some disk for /opt
resource "openstack_blockstorage_volume_v3" headnode {
  name = "hq-headnode-disk"
  description = "extra disk for the consul nodes"
  enable_online_resize = true
  size = 50 # Gb
}

resource "openstack_compute_volume_attach_v2" "headnode-vattach" {
  instance_id = openstack_compute_instance_v2.hq_server.id
  volume_id  = openstack_blockstorage_volume_v3.headnode.id
  # this does'nt seem to work for our hypervisor
  # device = "/dev/vdb"
}

# We partition and mount the disks last, then start the processes that
# rely on these disks.
resource "null_resource" headnode {

  depends_on = [  openstack_compute_instance_v2.hq_server ]

  provisioner "file" {
    source      = "./confs/docker"
    destination = "docker"
  }
  provisioner "file" {
    source      = "./scripts/mkfs_and_mount.sh"
    destination = "./mkfs_and_mount.sh"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT

      # partition and mount the extra disk
      DEVICE=${openstack_compute_volume_attach_v2.headnode-vattach.device}
      PART="$DEVICE"1
      chmod +x ./mkfs_and_mount.sh
      ./mkfs_and_mount.sh $DEVICE $PART /opt

      EOT
      ,
    ]
  }
  connection {
    type             = "ssh"
    user             = "ubuntu"
    private_key      = file("../z03.pem")
    host             = openstack_compute_instance_v2.hq_server.network[0].fixed_ip_v4
    bastion_user     = "centos"
    bastion_host     = var.bastion_ip
  }
}
*/