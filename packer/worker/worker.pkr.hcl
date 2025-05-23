locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  image_name = "${var.image_name}-${local.timestamp}"
}

source "openstack" "worker" {
  image_name                   = local.image_name
  flavor                       = var.flavor
  security_groups              = ["default", "ssh", "ping"]
  source_image                 = var.base_image_id
  ssh_keypair_name             = var.ssh_keypair_name
  ssh_bastion_host             = var.ssh_bastion_host
  ssh_bastion_private_key_file = var.ssh_bastion_private_key_file
  ssh_bastion_username         = var.ssh_bastion_username
  ssh_private_key_file         = var.ssh_private_key_file
  ssh_username                 = var.ssh_username

  # Image metadata
  metadata = {
    build_date    = "{{ timestamp }}"
    os_version    = "24.04"
    os_flavor     = "worker"
    builder       = "packer"
    base_image_id = var.base_image_id
    houdini_version = "20.5.584"
  }
}

build {

  sources = ["source.openstack.worker"]

  provisioner "file" {
    source      = "files/confs"
    destination = "confs"
  }

  provisioner "shell" {
    inline = [
      <<EOT

      echo NFS mounts z03 etc .......
      sudo apt-get -y install nfs-common
      sudo mkdir -p /g/data/z03
      sudo -- sh -c 'echo gdata1a.cloud.nci.org.au:/mnt/gdata1a/z03    /g/data/z03    nfs    _netdev,auto,hard,intr,timeo=10,retrans=10,vers=4 0 0 >> /etc/fstab'
      # mount the data disk
      #sudo mkdir -p /data
      #sudo -- sh -c 'echo ${var.vizfs_ip}:/data /data  nfs    _netdev,auto,hard,intr,timeo=10,retrans=10 0 0 >> /etc/fstab'

      # we want to use it now, so we mount
      #sudo mount /data
      # mount the opt of the server, not doing this any more
      #sudo -- sh -c 'echo hq-server-internal:/opt /opt  nfs    _netdev,auto,hard,intr,timeo=10,retrans=10 0 0 >> /etc/fstab'

      echo VizLab users .......
      # sudo groupadd -g 2202 z03
      # sudo useradd  -u 7634  -g z03 -s /bin/bash -m drw900
      # sudo usermod -aG sudo drw900
      # sudo useradd -u 10229 -g z03 -m z03_hqueue

      sudo groupadd -g 2202 hqgroup
      sudo useradd  -u 7634  -g hqgroup -s /bin/bash -m drw900
      sudo usermod -aG sudo drw900
      sudo useradd -u 10229 -g hqgroup -s /bin/bash -m hquser

      # this has now been added to the my_ubuntu_2024 image, maybe remove?
      #sudo apt-get -y install libglu1 libsm6 bc wget libnss3 libxcomposite1 libxrender1 libxrandr2 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libxss1 libpci3 libasound2
      sudo apt-get install -y python3 ffmpeg imagemagick

      # Intel OpenCL (leave out for the time being, does it work for new COPS?)
      #sudo mkdir -m 0755 -p /etc/apt/keyrings/
      #sudo wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor | sudo tee /etc/apt/keyrings/oneapi-archive-keyring.gpg > /dev/null
      #echo "deb [signed-by=/etc/apt/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main"  | sudo tee /etc/apt/sources.list.d/oneAPI.list
      #sudo apt-get update && sudo apt-get -y install intel-oneapi-runtime-libs

      EOT
      ,

    ]
  }

  # Make a ramdisk to save space in our image.
  provisioner "shell" {
    inline = [
      <<EOT
      # make a ramdisk
      sudo mkdir -p /mnt/ramdisk
      sudo mount -t tmpfs -o rw,size=16G tmpfs /mnt/ramdisk
      sudo mkdir -p /mnt/ramdisk/ubuntu
      sudo chown ubuntu:ubuntu /mnt/ramdisk/ubuntu
      EOT
      ,
    ]
  }

  provisioner "file" {
    source      = var.houdini_software_path
    destination = "/mnt/ramdisk/ubuntu/hh.tar.gz"
  }

  provisioner "shell" {
    inline = [
      <<EOT
      export EULA_DATE="2021-10-13"

      cd /mnt/ramdisk && sudo tar xvfz ./ubuntu/hh.tar.gz && cd houdini* && sudo ./houdini.install \
      --no-root-check\
      --auto-install \
      --no-install-license \
      --license-server-name 130.56.246.41 \
      --accept-EULA $EULA_DATE \
      --no-install-bin-symlink \
      --no-install-menus \
      --install-sidefxlabs \
      --no-install-hqueue-server \
      --no-install-hqueue-client

      sudo sh -c "cd /opt && mkdir -p houdini_distros && cd houdini_distros && ln -s /opt/hfs20.5 hfs.linux-x86_64"

      cd /mnt/ramdisk/houdini* && sudo ./houdini.install \
      --no-root-check\
      --auto-install \
      --no-install-houdini \
      --no-install-license \
      --license-server-name 130.56.246.41\
      --accept-EULA $EULA_DATE \
      --no-install-bin-symlink \
      --no-install-menus \
      --no-install-sidefxlabs \
      --install-hqueue-client \
      --hqueue-server-name hq-server-internal \
      --hqueue-server-port 5000 \
      --create-hqueue-shared-dir no \
      --mount-hqueue-shared-dir no\
      --hqueue-client-user hquser \
      --hqueue-client-dir /home/hquser/hqclient

#      --no-install-avahi

      # this changed for H20.5
      #sudo -u hquser /home/hquser/hqclient/hqclientd stop
      #sudo systemctl stop hqueue-client
      #sudo systemctl disable hqueue-client

      # clear out the logs
      sudo systemctl stop hqueue-client

      # cleanup
      cd $HOME
      sudo umount /mnt/ramdisk
      rm -fr confs hqclient/*.log
      EOT
      ,

    ]
  }

}