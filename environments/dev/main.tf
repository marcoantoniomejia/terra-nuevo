provider "google" {
  project = var.service_project_id
}

module "network" {
  source               = "../../modules/network"
  host_project_id      = var.host_project_id
  service_project_id   = var.service_project_id
  subnet_names         = ["subnet-dev01"]
  region               = var.region
  network_name         = "vpc-dev-shared"
}

module "compute" {
  source        = "../../modules/compute"
  project_id    = var.service_project_id
  subnets       = module.network.subnets
  instances = {
    "vm-dev-1" = {
      name         = "vm-dev-1"
      machine_type = "e2-medium"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-dev01"
      tags         = ["ambiente-dev"]
      external_ip  = true
    },
    "vm-dev-2" = {
      name         = "vm-dev-2"
      machine_type = "e2-medium"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-dev01"
      tags         = ["ambiente-dev"]
      external_ip  = true
    },
    "vm-dev-3" = {
      name         = "vm-dev-3"
      machine_type = "e2-medium"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-dev01"
      tags         = ["ambiente-dev"]
      external_ip  = true
    }
  }
}

module "cloud_sql" {
  source                   = "../../modules/cloud-sql"
  project_id               = var.service_project_id
  host_project_id          = var.host_project_id
  instance_name            = "cloud-sql-instance-dev"
  database_version         = "POSTGRES_13"
  tier                     = "db-g1-small"
  zone                     = "${var.region}-b"
  network_self_link        = module.network.network_self_link
  psa_peering_range_name   = "psa-googleservices-dev"
}
