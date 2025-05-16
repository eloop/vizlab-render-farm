#!/bin/sh
echo "Rebuilding hq3_worker image"

openstack image delete hq3_worker || true
packer build .
