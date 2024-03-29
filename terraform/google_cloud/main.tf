variable "project_name" {
  type = string
  default = "cicd-workshops"
}

variable "port_number" {
  type = string
  default = "5000"
}

variable "docker_declaration" {
  type = string
  # Change the image: string to match the docker image you want to use
  default = "spec:\n  containers:\n    - name: test-docker\n      image: '040772/python-cicd-workshop'\n      stdin: false\n      tty: false\n  restartPolicy: Always\n"
}


variable "boot_image_name" {
  type = string
  default = "projects/cos-cloud/global/images/cos-stable-69-10895-62-0"
}


######################
locals {
  project_number = "7396467160481603079"
  project_id     = "quick-filament-378505"
}
########################
data "google_compute_network" "default" {
   name = "default"
 }




# Specify the provider (GCP, AWS, Azure)
provider "google"{
  credentials = file("cicd_demo_gcp_creds.json")
  project = var.project_name
  region = "europe-west6"
}

resource "google_compute_firewall" "http-5000" {
  name    = "http-5000"
  network = data.google_compute_network.default.name
    allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.port_number]
  }
}

resource "google_compute_instance" "default" {
  name = "default"
  machine_type = "g1-small"
  zone = "europe-west6-a"
  tags =[
      "name","default"
  ]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.boot_image_name
      type = "pd-standard"
    }
  }

  metadata = {
    gce-container-declaration = var.docker_declaration
  }

  labels = {
    container-vm = "cos-stable-69-10895-62-0"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

output "Public_IP_Address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
