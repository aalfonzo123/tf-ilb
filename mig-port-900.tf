resource "google_compute_instance_template" "backend-vm-template-900" {
  name = "backend-vm-template"

  instance_description    = "backend vm"
  machine_type            = "e2-medium"
  region                  = var.network.region
  metadata_startup_script = "sudo socat TCP-LISTEN:900,fork FD:1&"

  # this will fail if the "Google APIs Service Agent" service account
  # is missing the "Tag User" role
  # that service account is: [project-number]@cloudservices.gserviceaccount.com
  resource_manager_tags = {
    (google_tags_tag_value.content-backend.parent) = google_tags_tag_value.content-backend.id
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = var.source-image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnetwork.id
  }

  service_account {
    email  = google_service_account.backend-sa.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_health_check" "backend-autoheal-health-check-900" {
  name                = "backend-autoheal-health-check-900"
  check_interval_sec  = 300
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10

  tcp_health_check {
    port = "900"
  }
}

resource "google_compute_region_instance_group_manager" "backend-mig-900" {
  name = "backend-mig-900"

  base_instance_name        = "backend-900"
  region                    = var.network.region
  distribution_policy_zones = var.ilb-zones

  version {
    instance_template = google_compute_instance_template.backend-vm-template-900.self_link_unique
  }

  target_size = 2

  # auto_healing_policies {
  #   health_check      = google_compute_health_check.backend-autoheal-health-check.id
  #   initial_delay_sec = 60
  # }

  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 0
    max_unavailable_fixed          = 2
    replacement_method             = "RECREATE"
  }
}