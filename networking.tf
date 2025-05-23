# We let the nodes talk to each other without restriction on the local
# netork.
resource "openstack_networking_secgroup_v2" "wideopen_group" {
  name        = "tf-wideopen-internal-rules"
  description = "for internal talk only"
}
resource "openstack_networking_secgroup_rule_v2" "wideopen_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "10.0.0.0/16"
  security_group_id = "${openstack_networking_secgroup_v2.wideopen_group.id}"
}

# This is the gateway where internal nodes will see Openstack floating IPs originating from.
resource "openstack_networking_secgroup_rule_v2" "wideopen_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "130.56.246.28/32"
  security_group_id = "${openstack_networking_secgroup_v2.wideopen_group.id}"
}

# # This is the gateway where internal nodes will see Openstack floating IPs originating from.
# resource "openstack_networking_secgroup_rule_v2" "wideopen_rule_3" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "icmp"
#   port_range_min    = 0
#   port_range_max    = 0
#   remote_ip_prefix  = "10.0.0.0/16"
#   security_group_id = "${openstack_networking_secgroup_v2.wideopen_group.id}"
# }

resource "openstack_networking_secgroup_v2" "external_group" {
  name        = "tf-external-rules"
  description = "Only open to certain IPs and ports"
}
#
# Rules for networking between farm and particular workstations
#

# hester
resource "openstack_networking_secgroup_rule_v2" "external_rule_1a_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000 # hq web server
  port_range_max    = 5000
  remote_ip_prefix  = "150.203.248.133/32" #hester
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}
resource "openstack_networking_secgroup_rule_v2" "external_rule_1b_mq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 37801
  port_range_max    = 37801
  remote_ip_prefix  = "150.203.248.133/32" #hester
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}

# boyd
resource "openstack_networking_secgroup_rule_v2" "external_rule_1c_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000 # hq web server
  port_range_max    = 5000
  remote_ip_prefix  = "150.203.248.58/32" #boyd
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}
resource "openstack_networking_secgroup_rule_v2" "external_rule_1d_mq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 37801
  port_range_max    = 37801
  remote_ip_prefix  = "150.203.248.58/32" #boyd
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}

# iq
resource "openstack_networking_secgroup_rule_v2" "external_rule_2_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "202.153.210.58/32" #iq
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}

# grainger
resource "openstack_networking_secgroup_rule_v2" "external_rule_3_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "150.203.248.74/32" #grainger
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}

# perceval
resource "openstack_networking_secgroup_rule_v2" "external_rule_4_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "150.203.248.62/32" #perceval
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}

# olley (ajay's laptop)
resource "openstack_networking_secgroup_rule_v2" "external_rule_5_hq" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 5000
  port_range_max    = 5000
  remote_ip_prefix  = "150.203.248.136/32" #perceval
  security_group_id = "${openstack_networking_secgroup_v2.external_group.id}"
}
