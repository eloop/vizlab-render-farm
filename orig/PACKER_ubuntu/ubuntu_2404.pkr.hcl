packer {
  required_plugins {
    openstack = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

source "openstack" "ubuntu" {

  image_name                   = "my_ubuntu_2404"
  flavor                       = "c3.2c4m10d"
  security_groups              = ["default", "ssh", "ping"]
  #source_image                 = "b2b3c40c-872a-4a1a-95ea-34bac32cf410"
  # latest server | 5c9c3111-c92f-48c2-8536-182683ae28fc | Ubuntu Jammy Server 2024-06-01              | active      |
  #               | fbc1e681-bd20-486b-b42c-5fa5f9f554f5 | Ubuntu Jammy Minimal Cloud Image 2023-02-13 | active      |
  #               | 2739e944-abd1-42e7-a0e3-929b221c002f | Ubuntu Noble Server 2024-10-04              | active      |
  source_image                 = "2739e944-abd1-42e7-a0e3-929b221c002f"
  ssh_keypair_name             = "z03"
#  ssh_bastion_host             = "130.56.246.26"
#  ssh_bastion_private_key_file = "../../z03.pem"
#  ssh_bastion_username         = "centos"
  ssh_private_key_file         = "../../z03.pem"
  ssh_username                 = "ubuntu"
}

build {
  sources = ["source.openstack.ubuntu"]
  provisioner "shell" {
    inline = [
      <<EOT
      sleep 20

      # try and shutup the errors ...
      echo "set debconf to Noninteractive"
      export DEBIAN_FRONTEND=noninteractive
      echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

      sudo apt-get update -y
      sudo apt-get upgrade -y

      echo Useful tools .......
      sudo apt-get install -y tree emacs-nox btop htop cmake git wget kitty-terminfo jq apt-utils python3

      # a bunch of requirements need to install a desktop Houdini
      sudo apt-get -y install libglu1 libsm6 bc wget libnss3 libxcomposite1 libxrender1 libxrandr2 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libxss1 libpci3 python3 ffmpeg imagemagick

      # 22.04 wanted libasound2, which isn't in 24.04
      # sudo apt-get -y install libglu1 libsm6 bc wget libnss3 libxcomposite1 libxrender1 libxrandr2 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libxss1 libpci3 libasound2 python3 ffmpeg imagemagick

      echo Done updating and upgrading an Ubuntu 24.04.
      EOT
      ,
    ]
  }
}
