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
    source      = "${path.module}/confs"
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
  depends_on = [
    openstack_compute_instance_v2.hq_worker,
    local_file.hosts
  ]

  # this works wonders!! :-)
  triggers = {
    instance_id = openstack_compute_instance_v2.hq_worker[count.index].id
    n_workers = var.n_workers
    hosts_content = filemd5("${path.module}/confs/hosts")
  }

  provisioner "file" {
    source      = "${path.module}/confs"
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




