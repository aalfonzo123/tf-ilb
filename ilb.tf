data "google_compute_subnetwork" "subnetwork" {
  name   = var.network.subnetwork-name
  region = var.network.region
}

resource "google_compute_address" "ilb_address" {
  name         = "ilb-address"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnetwork.id
  region       = var.network.region
  purpose      = "SHARED_LOADBALANCER_VIP"
}

# port 800

resource "google_compute_region_health_check" "backend-ilb-health-check-800" {
  name                = "backend-ilb-health-check-800"
  region              = var.network.region
  check_interval_sec  = 300
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 5 # 25 seconds

  tcp_health_check {
    port = "800"
  }
}

resource "google_compute_region_backend_service" "backend-800" {
  name                  = "backend-800"
  region                = var.network.region
  load_balancing_scheme = "INTERNAL"
  backend {
    group          = google_compute_region_instance_group_manager.backend-mig-800.instance_group
    balancing_mode = "CONNECTION"
  }
  health_checks = [google_compute_region_health_check.backend-ilb-health-check-800.id]
}

resource "google_compute_forwarding_rule" "forwarding-rule-port-800" {
  name                  = "forwarding-rule-port-800"
  ip_protocol           = "TCP"
  ports                 = ["800"]
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_address.id
  backend_service       = google_compute_region_backend_service.backend-800.id
  region                = var.network.region
  network               = data.google_compute_network.network.id
  subnetwork            = data.google_compute_subnetwork.subnetwork.id
}

# port 900

resource "google_compute_region_health_check" "backend-ilb-health-check-900" {
  name                = "backend-ilb-health-check-900"
  region              = var.network.region
  check_interval_sec  = 300
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 5 # 25 seconds

  tcp_health_check {
    port = "900"
  }
}


resource "google_compute_region_backend_service" "backend-900" {
  name                  = "backend-900"
  region                = var.network.region
  load_balancing_scheme = "INTERNAL"
  backend {
    group          = google_compute_region_instance_group_manager.backend-mig-900.instance_group
    balancing_mode = "CONNECTION"
  }
  health_checks = [google_compute_region_health_check.backend-ilb-health-check-900.id]
}


resource "google_compute_forwarding_rule" "forwarding-rule-port-900" {
  name                  = "forwarding-rule-port-900"
  ip_protocol           = "TCP"
  ports                 = ["900"]
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.ilb_address.id
  backend_service       = google_compute_region_backend_service.backend-900.id
  region                = var.network.region
  network               = data.google_compute_network.network.id
  subnetwork            = data.google_compute_subnetwork.subnetwork.id
}

