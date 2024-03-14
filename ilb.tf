resource "google_compute_region_health_check" "backend-ilb-health-check" {
  name                = "backend-ilb-health-check"
  region              = var.network.region
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 5 # 25 seconds

  tcp_health_check {
    port = "800"
  }
}

resource "google_compute_region_backend_service" "backend" {
  #  provider              = google-beta
  name                  = "backend"
  region                = var.network.region
  load_balancing_scheme = "INTERNAL"
  backend {
    group          = google_compute_region_instance_group_manager.backend-mig.instance_group
    balancing_mode = "CONNECTION"
  }
  health_checks = [google_compute_region_health_check.backend-ilb-health-check.id]
}

resource "google_compute_forwarding_rule" "forwarding-rule-port-800" {
  name = "forwarding-rule-port-800"
  #  provider              = google-beta
  ip_protocol           = "TCP"
  ports                 = ["800"]
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.backend.id
  region                = var.network.region
  network               = data.google_compute_network.network.id
  subnetwork            = data.google_compute_subnetwork.subnetwork.id
}



