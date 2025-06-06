#!/bin/env python3
#
# simple script for generating a host file for the cluster
#

subnet = 7

boilerplate = """127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts

# do not edit, the following are autogenerated ....

# Note: this floating IP named hqserver is attached to frontend which proxies across hqserver internally.
# This is the entry you need to make on the workstations using the farm.

130.56.246.40 hq-server

"""
print(boilerplate)
print(f"""10.0.{subnet}.253 hq-server-internal""")

# file server
print(f"""10.0.0.20 vizfs""")

# license server
print(f"""10.0.1.216 newlicenses""")



# nomad clients
nworkers = 240
for i in range(1,nworkers):
    print(f"""10.0.{subnet}.{i} hq-worker-{i:03d}""")
