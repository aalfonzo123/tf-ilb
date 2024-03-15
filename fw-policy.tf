data "google_project" "project" {
  project_id = var.network.project-id
}

data "google_compute_network" "network" {
  name    = var.network.vpc-name
  project = var.network.project-id
}

resource "google_compute_network_firewall_policy" "content-fw-policy" {
  project     = data.google_project.project.id
  name        = "${var.network.vpc-name}-content-fw-policy"
  description = "Content firewall policy"
}

resource "google_compute_network_firewall_policy_association" "fw-policy-vpc-association" {
  name              = "fw-policy-vpc-association"
  attachment_target = data.google_compute_network.network.id
  firewall_policy   = google_compute_network_firewall_policy.content-fw-policy.name
  project           = data.google_project.project.id
}

resource "google_compute_network_firewall_policy_rule" "fw-allow-health-check-backend" {
  project         = data.google_project.project.id
  action          = "allow"
  description     = "fw-allow-health-check-backend"
  direction       = "INGRESS"
  firewall_policy = google_compute_network_firewall_policy.content-fw-policy.name
  priority        = 1000
  rule_name       = "fw-allow-health-check-backend"
  target_secure_tags {
    name = google_tags_tag_value.content-backend.id
  }

  match {
    # Google Cloud health checking systems
    src_ip_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = [800, 900]
    }
  }
}

# optional: for IAP
resource "google_compute_network_firewall_policy_rule" "fw-allow-iap-ssh-backend" {
  project         = data.google_project.project.id
  action          = "allow"
  description     = "fw-allow-iap-ssh-backend"
  direction       = "INGRESS"
  firewall_policy = google_compute_network_firewall_policy.content-fw-policy.name
  priority        = 1001
  rule_name       = "fw-allow-iap-ssh-backend"

  match {
    # Google Cloud health checking systems
    src_ip_ranges = ["35.235.240.0/20"]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = [22]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "fw-allow-inter-backend" {
  project         = data.google_project.project.id
  action          = "allow"
  description     = "fw-allow-inter-backend"
  direction       = "INGRESS"
  firewall_policy = google_compute_network_firewall_policy.content-fw-policy.name
  priority        = 1002
  rule_name       = "fw-allow-inter-backend"

  match {
    src_ip_ranges = [data.google_compute_subnetwork.subnetwork.ip_cidr_range]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = [800, 900]
    }
  }
}

