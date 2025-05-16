#!/bin/env bash
#
# This is something you'd typically want to do when you want to
# upgrade to a newer version of Houdini which is pointed to by
# hh.tar.gz.
#
echo "Rebuilding everything!"

./rebuild_images.sh

terraform destroy -auto-approve && terraform apply -auto-approve 2>&1 log.txt &

tail -f log.txt
