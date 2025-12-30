locals {
  peering_range = var.psa_peering_range_name != "" ? var.psa_peering_range_name : google_compute_global_address.private_ip_address[0].name
}

resource "google_sql_database_instance" "instance" {
  project          = var.project_id
  name             = var.instance_name
  database_version = var.database_version
  region           = substr(var.zone, 0, length(var.zone) - 2)

  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service" "private_service_access" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "private_ip_address" {
  count         = var.psa_peering_range_name == "" ? 1 : 0
  project       = var.host_project_id
  name          = "private-ip-for-sql-${var.instance_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20 # As per user request
  network       = var.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = var.create_service_networking_connection ? 1 : 0
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [local.peering_range]

  depends_on = [google_project_service.private_service_access]
  }