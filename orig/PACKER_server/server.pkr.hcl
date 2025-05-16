source "openstack" "server" {
  image_name                   = "hq3_server"
  flavor                       = "c3pl.16c32m20d"
  security_groups              = ["default", "ssh", "ping"]
  source_image_name            = "my_ubuntu_2404"
  ssh_keypair_name             = "z03"
  ssh_bastion_host             = "130.56.246.26"
  ssh_bastion_private_key_file = "../../z03.pem"
  ssh_bastion_username         = "centos"
  ssh_private_key_file         = "../../z03.pem"
  ssh_username                 = "ubuntu"
}

build {

  sources = ["source.openstack.server"]

  # We make a ramdisk to save space in the image, got this idea from
  # Docker image building.
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
    source      = "../hh.tar.gz"
    destination = "/mnt/ramdisk/ubuntu/hh.tar.gz"
  }

  provisioner "file" {
    source      = "../confs"
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
      # sudo mkdir -p /data
      # sudo -- sh -c 'echo ${var.vizfs_ip}:/data /data  nfs    _netdev,auto,hard,intr,timeo=10,retrans=10 0 0 >> /etc/fstab'
      # # we want to use it now, so we mount
      # sudo mount /data

      # not doing /opt exporting this anymore.................
      # export /opt to the workers
      # sudo apt-get -y install nfs-kernel-server
      # sudo sh -c 'echo "\n/opt 10.0.0.0/16(rw,sync,no_subtree_check)\n" >> /etc/exports'
      # sudo exportfs -a

      echo VizLab users .......

      # sudo groupadd -g 2202 z03
      # sudo useradd  -u 7634  -g z03 -s /bin/bash -m drw900
      # sudo usermod -aG sudo drw900
      # sudo useradd -u 10229 -g z03 -m z03_hqueue

      sudo groupadd -g 2202 hqgroup
      sudo useradd  -u 7634  -g hqgroup -s /bin/bash -m drw900
      sudo usermod -aG sudo drw900
      sudo useradd -u 10229 -g hqgroup -s /bin/bash -m hquser

      # this is now in  my_ubuntu_2024 image, so shouldn't take too much time here, maybe remove?
      #sudo apt-get -y install libglu1 libsm6 bc wget libnss3 libxcomposite1 libxrender1 libxrandr2 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libxss1 libpci3 libasound2 python3 ffmpeg imagemagick

      EULA_DATE="2021-10-13"

      cd /mnt/ramdisk/ubuntu && sudo tar xvfz ./hh.tar.gz && cd houdini* && sudo ./houdini.install \
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

      # install server
      cd /mnt/ramdisk/ubuntu && cd houdini* && sudo ./houdini.install \
        --no-root-check\
        --auto-install \
        --no-install-license \
        --license-server-name 130.56.246.41\
        --accept-EULA $EULA_DATE \
        --no-install-houdini \
        --no-install-avahi \
        --no-install-bin-symlink \
        --no-install-menus \
        --no-install-sidefxlabs \
        --install-hqueue-server\
        --hqueue-server-dir /opt/hqueue

      # this changed for H20.5
      #sudo /opt/hqueue/scripts/hqserverd stop
      #sudo systemctl stop hqueue-server
      #sudo systemctl disable hqueue-server

      sudo sh -c "cd /opt && mkdir -p houdini_distros && cd houdini_distros && ln -s /opt/hfs20.5 hfs.linux-x86_64"

       # install a client on our server, but we'll have it turned off
      cd /mnt/ramdisk/ubuntu && cd houdini* && sudo ./houdini.install \
      --no-root-check\
      --auto-install \
      --no-install-houdini \
      --no-install-license \
      --license-server-name 130.56.246.41\
      --accept-EULA $EULA_DATE \
      --no-install-avahi \
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

      # this changed for H20.5, we stop the client running on the server by default
      #sudo -u hquser /home/hquser/hqclient/hqclientd stop
      sudo systemctl stop hqueue-client
      sudo systemctl disable hqueue-client


      # cleanup
      cd $HOME
      rm -r confs
      sudo umount /mnt/ramdisk
      #sudo sh -c "cd /mnt/ramdisk/ubuntu && rm -rf houdini*"
      EOT
      ,

    ]
  }
}
