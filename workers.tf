# -*- terraform -*-

# These are the worker nodes.

resource "openstack_compute_instance_v2" "hq_worker" {

  timeouts {
    create = "1h"
    update = "1h"
    delete = "20m"
  }

  depends_on = [
    #openstack_compute_instance_v2.hq_server,
    #openstack_blockstorage_volume_v2.slurm_data
  ]

  # these are all be hidden from external view
  security_groups = [
    "default", "ssh", "ping",
    "${openstack_networking_secgroup_v2.wideopen_group.name}"
  ]

  count       = var.n_workers
  name        = "hq-worker-${format("%03d",count.index+1)}"
  image_id    = var.worker_image_id
  flavor_name = "c3pl.16c32m20d"

  key_pair    = "z03"

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.hq-server-group.id}"
  }

  network {
    uuid        = "9227876a-c00a-4bc7-8cc5-4419b75f5bc5"
    fixed_ip_v4 = "${var.cluster_subnet}.${count.index+1}"
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
    source      = "./confs"
    destination = "confs"
  }

  provisioner "local-exec" {
    # convenience function, may remove at a later date
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${self.network[0].fixed_ip_v4} || true"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
      sleep 10s
      EOT
    ]
  }
}

# We do this separately so we can reconfigure without taking down all
# the VMs. Not doing much here anymore
resource "null_resource" "worker_configure" {

  count       = var.n_workers
  depends_on = [  openstack_compute_instance_v2.hq_worker ]

  # this works wonders!! :-)
  triggers = {
    n_workers = var.n_workers
    hosts_content = filemd5("${path.module}/confs/hosts")
  }

  provisioner "file" {
    source      = "./confs"
    destination = "confs"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
      sudo cp ./confs/hosts /etc/hosts
      sudo mount -a
      sudo cp ./confs/hqserver/sesi_licenses.pref /home/hquser/.sesi_licenses.pref
      sudo chown hquser:hqgroup /home/hquser/.sesi_licenses.pref

      # drw900 - H20.5
      #sudo cp ./confs/hqclient/hqclient.service /etc/systemd/system
      #sudo systemctl enable hqclient
      #sudo systemctl restart hqclient

      rm -rf confs
      EOT
      ,
    ]
  }

  connection {
    type             = "ssh"
    user             = var.ssh_username
    private_key      = file(var.ssh_private_key_file)
    host             = openstack_compute_instance_v2.hq_worker[count.index].network[0].fixed_ip_v4
    #bastion_user     = var.bastion_username
    #bastion_host     = var.bastion_host
  }
}





# ---- OLD STUFF ------------------------------------------------------------------------------------------------

# some disk for /opt

# resource "openstack_blockstorage_volume_v3" "hq_worker" {
#   count       = var.n_workers
#   name = "hq-worker-disk-${count.index}"
#   description = "extra disk for workers"
#   enable_online_resize = true
#   size = 25 # Gb
# }

# resource "openstack_compute_volume_attach_v2" "hq_worker_vattach" {
#   count       = var.n_workers
#   instance_id = openstack_compute_instance_v2.hq_worker[count.index].id
#   volume_id  = openstack_blockstorage_volume_v3.hq_worker[count.index].id
#   #device = "/dev/vdb"
# }

# # We partition and mount the disks last.
# resource "null_resource" "worker" {

#   count       = var.n_workers

#   depends_on = [  openstack_compute_instance_v2.hq_worker ]

#   triggers =  {
#     disksize = openstack_blockstorage_volume_v3.hq_worker[count.index].size
#   }

#   provisioner "file" {
#     source      = "./confs/docker"
#     destination = "docker"
#   }

#   provisioner "file" {
#     source      = "./scripts/mkfs_and_mount.sh"
#     destination = "./mkfs_and_mount.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # partition and mount the extra disk
#       <<EOT
#       DEVICE=${openstack_compute_volume_attach_v2.hq_worker_vattach[count.index].device}
#       PART="$DEVICE"1

#       chmod +x ./mkfs_and_mount.sh
#       ./mkfs_and_mount.sh $DEVICE $PART /opt


#       EOT
#       ,
#     ]
#   }

#   connection {
#     type             = "ssh"
#     user             = "ubuntu"
#     private_key      = file("../z03.pem")
#     host             = openstack_compute_instance_v2.hq_worker[count.index].network[0].fixed_ip_v4
#     bastion_user     = "centos"
#     bastion_host     = var.bastion_ip
#   }
# }

#
#
# drw900@hester:~/Dropbox/VM_Management/cloud.nci.org.au$ openstack flavor list
# +--------------------------------------+------------------+-------+------+-----------+-------+-----------+
# | ID                                   | Name             |   RAM | Disk | Ephemeral | VCPUs | Is Public |
# +--------------------------------------+------------------+-------+------+-----------+-------+-----------+
# | 0333e746-86eb-4d92-9c25-e762d83e2ef7 | c3.1c2m10d       |  2048 |   10 |         0 |     1 | True      |
# | 3a58bba0-b055-43d5-97e6-e4b8970c97a0 | c3pl.16c48m60d   | 49152 |   10 |        50 |    16 | False     |
# | 42bb374d-f836-4c8c-a1b6-32fcd3bbc4f0 | c3pl.16c30m210d  | 30720 |   10 |       200 |    16 | False     |
# | 6e8470b4-09e2-4e27-bd74-e84f9c7309ea | c3.1c1m5d        |  1024 |    5 |         0 |     1 | True      |
# | 745ed175-a555-46b1-b330-5a438cc0d35d | c3pl.16c58m210d  | 59392 |   10 |       200 |    16 | False     |
# | 86ce15a5-3848-43df-85ac-a3d5cf57b6c9 | c3pl.16c60m210d  | 61440 |   10 |       200 |    16 | False     |
# | a81157b5-b3ac-4704-a451-6c65392db107 | c3gpu.7c28m70d1g | 28672 |   20 |        50 |     7 | False     |
# | c530ae95-b7b8-4808-b2e6-8c78e8f64458 | c3.1c0.5m1d      |   512 |    1 |         0 |     1 | True      |
# | de078925-e724-4541-8ddd-cab3889b0908 | c3.4c8m10d       |  8192 |   10 |         0 |     4 | True      |
# | f1a7f728-4b03-4ac2-b492-aa0ebad55e89 | c3.2c4m10d       |  4096 |   10 |         0 |     2 | True      |
# | f989f36b-46a0-4efc-9749-eaa5eac248a3 | c3.8c16m10d      | 16384 |   10 |         0 |     8 | True      |
# +--------------------------------------+------------------+-------+------+-----------+-------+-----------+
