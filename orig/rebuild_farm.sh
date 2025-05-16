#!/bin/env bash
#
# This is something you'd typically want to do when you want to
# upgrade to a newer version of Houdini which is pointed to by
# hh.tar.gz.
#
set -e
# Exit if any command in a pipeline fails
set -o pipefail

echo "Rebuilding just the farm, not images."

terraform destroy -auto-approve
terraform apply -auto-approve
