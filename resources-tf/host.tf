resource "google_compute_address" "ext_addr" {
  name = "ethereum-node"
  address_type = "EXTERNAL"
}

resource "google_dns_record_set" "dns_record" {
  name = "eth.rchain-dev.tk."
  managed_zone = "rchain-dev"
  type = "A"
  ttl = 300
  rrdatas = ["${google_compute_address.ext_addr.address}"]
}

resource "google_compute_disk" "data_disk" {
  name = "ethereum-node-data"
  type = "pd-ssd"
  size = 500
}

resource "google_compute_instance" "host" {
  name = "ethereum-node"
  hostname = "eth.rchain-dev.tk"
  machine_type = "n1-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-1904"
      size = 20
      type = "pd-standard"
    }
  }

  attached_disk {
    source = "${google_compute_disk.data_disk.self_link}"
    device_name = "ethereum-node-data"
  }

  tags = [
    "ethereum",
    "collectd-out",
  ]

  network_interface {
    network = "${data.google_compute_network.default_network.self_link}"
    access_config {
      nat_ip = "${google_compute_address.ext_addr.address}"
    }
  }

  depends_on = [ "google_dns_record_set.dns_record" ]

  connection {
    type = "ssh"
    user = "root"
    private_key = "${file("~/.ssh/google_compute_engine")}"
  }

  provisioner "file" {
    source = "${var.rchain_sre_git_crypt_key_file}"
    destination = "/root/rchain-sre-git-crypt-key"
  }

  provisioner "remote-exec" {
    script = "../bootstrap"
  }
}
