terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_address" "static" {
  name = var.instance_name
}

resource "google_compute_instance" "instance" {
  name         = var.instance_name
  machine_type = "n1-standard-1"

  metadata = {
    ssh-keys = "${var.username}:${file(var.public_key)}"
  }


  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7-v20220621"
      size = 100
    }
  }



  network_interface {
    network = "default"

     access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  // Apply the firewall rule to allow external IPs to access this instance
  tags = ["http-server", "https-server", "minio"]


    provisioner "file" {
    source      = "minio.sh"
    destination = "/tmp/minio.sh"

    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = var.username
      private_key = file(var.private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/minio.sh",
      "sudo /tmp/minio.sh",
    ]

    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = var.username
      private_key = file(var.private_key)
    }

  }
}



### Disable if you already created this firewall rules ###

# resource "google_compute_firewall" "http-server" {
#   name    = "default-allow-http"
#   network = "default"

#    allow {
#    protocol = "tcp"
#     ports    = ["80"]
#   }

#   // Allow traffic from everywhere to instances with an http-server tag
#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["http-server"]
# }

# resource "google_compute_firewall" "https-server" {
#   name    = "default-allow-https"
#   network = "default"

#    allow {
#    protocol = "tcp"
#     ports    = ["443"]
#   }

#   // Allow traffic from everywhere to instances with an http-server tag
#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["https-server"]
# }

# resource "google_compute_firewall" "minio" {
#   name    = "minio"
#   network = "default"

#    allow {
#    protocol = "tcp"
#     ports    = ["9000"]
#   }

#   // Allow traffic from everywhere to instances with an http-server tag
#   source_ranges = ["0.0.0.0/0"]
#   target_tags   = ["minio"]
# }



output "instance_external_ip" {
  value = "${google_compute_instance.instance.network_interface.0.access_config.0.nat_ip}"
}

output "instance_internal_ip" {
  value = "${google_compute_instance.instance.network_interface.0.network_ip}"
}
