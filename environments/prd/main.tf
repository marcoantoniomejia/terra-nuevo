provider "google" {
  project = var.service_project_id
}

module "network" {
  source               = "../../modules/network"
  host_project_id      = var.host_project_id
  service_project_id   = var.service_project_id
  subnets              = module.network.subnets
}

module "compute" {
  source        = "../../modules/compute"
  project_id    = var.service_project_id
  subnets       = module.network.subnets
  instances = {
    "vm-external-1" = {
      name         = "vm-external-1"
      machine_type = "e2-standard-2"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-external-1"
      tags         = ["usuario=user1", "ambiente=prd"]
      external_ip  = true
    },
    "vm-external-2" = {
      name         = "vm-external-2"
      machine_type = "e2-standard-2"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-external-1"
      tags         = ["usuario=user1", "ambiente=prd"]
      external_ip  = true
    },
    "vm-internal-1" = {
      name         = "vm-internal-1"
      machine_type = "e2-standard-2"
      zone         = "${var.region}-b"
      subnet_name  = "subnet-internal-1"
      tags         = ["usuario=user2", "ambiente=prd"]
      external_ip  = false
    }
  }
}

module "cloud_sql" {
  source           = "../../modules/cloud-sql"
  project_id       = var.service_project_id
  instance_name    = "cloud-sql-instance-1"
  database_version = "POSTGRES_13"
  tier             = "db-n1-standard-1"
  zone             = "${var.region}-b"
  subnet_name      = "subnet-external-2"
  subnets          = module.network.subnets
}
