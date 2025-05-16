# tailscale key for the headnode
variable "tailscale_key" {
  type      = string
  default   = "tskey-auth-kjGd1n2CNTRL-kzTFCNvrMahhQbFCNvrMahqBUBEp8aiqX"
  sensitive = true
}
variable "tailscale_api_key" {
  type      = string
  default   = "tskey-api-k2HdG33CNTRL-DXsWCfhjzcKSa5XCfhjzcKQUmVtUChcSH"
  sensitive = true
}
