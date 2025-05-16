#!/bin/env bash

set -e

# update the configuration for all the nodes.
terraform destroy -auto-approve -target=null_resource.worker_configure
terraform apply -auto-approve
