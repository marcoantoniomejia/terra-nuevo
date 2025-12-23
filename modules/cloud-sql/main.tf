resource "google_sql_database_instance" "instance" {
  project          = var.project_id
  name             = var.instance_name
  database_version = var.database_version
  region           = var.subnets[var.subnet_name].region

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
  project       = var.subnets[var.subnet_name].project
  name          = "private-ip-for-sql"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]

  depends_on = [google_project_service.private_service_access]
}
