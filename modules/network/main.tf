resource "google_compute_subnetwork" "subnets" {
  for_each      = var.subnets
  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = each.value.region
  network       = "projects/${var.host_project_id}/global/networks/vop-prd-shared-vop"
  project       = var.host_project_id

  private_ip_google_access = lookup(each.value, "private_ip_google_access", true)
}

resource "google_compute_shared_vpc_service_project" "service_project_attachment" {
  host_project    = var.host_project_id
  service_project = var.service_project_id
}
