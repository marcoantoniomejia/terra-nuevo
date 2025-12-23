data "google_compute_subnetwork" "subnets" {
  for_each = toset(var.subnet_names)
  name     = each.key
  project  = var.host_project_id
  region   = var.region
}

resource "google_compute_shared_vpc_service_project" "service_project_attachment" {
  host_project    = var.host_project_id
  service_project = var.service_project_id
  depends_on = [data.google_compute_subnetwork.subnets]
}
