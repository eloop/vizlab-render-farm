# data_dir tends to be environment specific.
data_dir = "/opt/nomad/data"

server {
  enabled = true
  bootstrap_expect = 3
  # server_join {
  #   #start_join = ["10.0.6.255", "10.0.6.240", "10.0.6.241"]
  #   retry_join = ["10.0.6.255"]
  #   retry_interval = "15s"
  # }
}
