#!/bin/env bash
#
# This is something you'd typically want to do when you want to
# upgrade to a newer version of Houdini which is pointed to by
# hh.tar.gz.
#
echo "Rebuilding the image!"
# Exit immediately if a command exits with a non-zero status.
set -e

# Exit if any command in a pipeline fails
set -o pipefail

# This is required by the other images.
pushd ./PACKER_ubuntu
./rebuild.sh
popd

pushd ./PACKER_server
./rebuild.sh 2>&1 > log_server.txt &
pid1=$!
popd

pushd ./PACKER_worker
./rebuild.sh 2>&1 log_worker.txt &
pid2=$!
popd

wait $pid1 $pid2
