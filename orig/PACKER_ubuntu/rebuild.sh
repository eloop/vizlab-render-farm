#!/bin/sh
echo "Rebuilding my_ubuntu_2204 image"

openstack image delete my_ubuntu_2404 || true

packer build .
