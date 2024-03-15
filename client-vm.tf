resource "google_compute_instance" "client-instance" {
  name                      = "client-instance"
  machine_type              = "e2-medium"
  zone                      = "us-east4-a"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = "30"
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnetwork.id
  }

  scheduling {
    provisioning_model = "SPOT"
    # provisioning_model = "STANDARD"
    preemptible                 = true
    automatic_restart           = false
    instance_termination_action = "STOP"
  }

  service_account {
    email  = google_service_account.backend-sa.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}