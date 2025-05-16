#!/bin/sh
echo "Rebuilding hq3_server image"

openstack image delete hq3_server || true

packer build .
