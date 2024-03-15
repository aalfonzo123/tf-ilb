resource "google_tags_tag_key" "content-tag" {
  parent      = data.google_project.project.id
  short_name  = "${var.network.vpc-name}-content-tag"
  description = "Tag example"
  purpose     = "GCE_FIREWALL"
  purpose_data = {
    network = "${var.network.project-id}/${var.network.vpc-name}"
  }
}

resource "google_tags_tag_value" "content-database" {
  parent      = "tagKeys/${google_tags_tag_key.content-tag.name}"
  short_name  = "database"
  description = "database content"
}

resource "google_tags_tag_value" "content-backend" {
  parent      = "tagKeys/${google_tags_tag_key.content-tag.name}"
  short_name  = "backend"
  description = "backend content"
}

variable "roles" {
  type        = list(string)
  description = "The roles that will be granted to the service account."
  default     = ["roles/resourcemanager.tagUser"]
}


# Without this iam binding, the instance group will
# not be able to attach the tag to new VMS
resource "google_project_iam_member" "sa_iam" {
  role    = "roles/resourcemanager.tagUser"
  project = data.google_project.project.project_id
  member  = "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com"
}