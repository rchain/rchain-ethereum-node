data "google_compute_network" "default_network" {
  name = "default"
}

resource "google_compute_firewall" "fw_rpc" {
  name = "ethereum-rpc"
  network = "${data.google_compute_network.default_network.self_link}"
  priority = 510
  target_tags = [ "ethereum" ]
  allow {
    protocol = "tcp"
    ports = [ 8545, 8546 ]
  }
  disabled = "true"
}

resource "google_compute_firewall" "fw_p2p" {
  name = "ethereum-p2p"
  network = "${data.google_compute_network.default_network.self_link}"
  priority = 520
  target_tags = [ "ethereum" ]
  allow {
    protocol = "tcp"
    ports = [ 30303 ]
  }
  allow {
    protocol = "udp"
    ports = [ 30303, 30304 ]
  }
}
