terraform {
  required_version = "0.12.5"
}
provider "google" {
  version = "2.5"
  project = "${var.project}"
  region  = "${var.region}"
}
resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${vars.zone}"
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  metadata = {
    ssh-keys = "knut020:${file("${var.public_key_path}")}"
  }
  connection {
    host        = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"
    type        = "ssh"
    user        = "knut020"
    agent       = false
    private_key = "${file("${vars.ssh_private_key}")}"
  }
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}
resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
