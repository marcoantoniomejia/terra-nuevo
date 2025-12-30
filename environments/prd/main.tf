provider "google" {
  project = var.service_project_id
}

module "network" {
  source                          = "../../modules/network"
  host_project_id                 = var.host_project_id
  service_project_id              = var.service_project_id
  subnet_names                    = var.subnet_names
  region                          = var.region
  network_name                    = var.network_name
  create_service_project_attachment = var.create_service_project_attachment
}

module "compute" {
  source        = "../../modules/compute"
  project_id    = var.service_project_id
  subnets       = module.network.subnets
  instances     = var.compute_instances
}

module "cloud_sql" {
  source                               = "../../modules/cloud-sql"
  project_id                           = var.service_project_id
  host_project_id                      = var.host_project_id
  instance_name                        = var.cloud_sql_instance_name
  database_version                     = var.cloud_sql_database_version
  tier                                 = var.cloud_sql_tier
  zone                                 = var.cloud_sql_zone
  network_self_link                    = module.network.network_self_link
  psa_peering_range_name               = var.cloud_sql_psa_peering_range_name
  create_service_networking_connection = var.create_service_networking_connection
}
