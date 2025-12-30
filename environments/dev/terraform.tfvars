host_project_id    = "vpc-host-dev-414119"
service_project_id   = "iwx-infra-01-dev"
region               = "us-central1"
create_service_project_attachment = false
create_service_networking_connection = false

subnet_names = ["subnet-dev01"]
network_name = "vpc-dev-shared"

compute_instances = {
  "vm-dev-1" = {
    name         = "vm-dev-1"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-dev01"
    tags         = ["ambiente-dev"]
    external_ip  = true
  },
  "vm-dev-2" = {
    name         = "vm-dev-2"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-dev01"
    tags         = ["ambiente-dev"]
    external_ip  = true
  },
  "vm-dev-3" = {
    name         = "vm-dev-3"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-dev01"
    tags         = ["ambiente-dev"]
    external_ip  = true
  }
}

cloud_sql_instance_name    = "cloud-sql-instance-dev"
cloud_sql_database_version = "POSTGRES_13"
cloud_sql_tier             = "db-g1-small"
cloud_sql_zone             = "us-central1-b"
cloud_sql_psa_peering_range_name = "psa-googleservices-dev"
