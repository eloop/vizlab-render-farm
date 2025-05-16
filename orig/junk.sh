#!/bin/env bash

AUTH='tskey-auth-kgqnoxRaqu11CNTRL-4k7JbeVCDYfPZzHbeVCDYfCPGE71G27f'
API='tskey-api-kgsUfnMpE511CNTRL-zubpVf8cDXBMGjpVf8cDXBz3UANA1gVZQ'
NAME="hq-server-1"

json_data=$(curl -s 'https://api.tailscale.com/api/v2/tailnet/drew.whitehouse@gmail.com/devices' -u "${API}:")

echo $json_data

# nodeids=$(echo "${json_data}" | jq --arg hostName "${NAME}" -r '.devices[] | select(.hostname == $hostName ) | .nodeId')

# echo json_data=$json_data

# echo nodeids=$nodeids

# curl 'https://api.tailscale.com/api/v2/tailnet/drew.whitehouse@gmail.com/devices' -u "${API}:" | \
# jq --arg hostName "${NAME}" -r '.devices[] | select(.hostname == $hostName ) | .nodeId' | \
# while IFS= read -r nodeid; do
#     echo nodeid = $nodeid
#     #echo curl --request DELETE --url "https://api.tailscale.com/api/v2/device/$nodeid" -u "${API}:" -v
#     #curl -X DELETE "https://api.tailscale.com/api/v2/device/$nodeid" -u "${API}:" -v
# done
