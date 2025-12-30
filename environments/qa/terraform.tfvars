# Por favor, revisa y ajusta estos valores para que coincidan con tu ambiente de QA.
# Los project_id se han asumido siguiendo el patrón de 'dev'.

host_project_id    = "vpc-host-qa-xxxxxx"  # <-- AJUSTAR
service_project_id   = "iwx-infra-01-qa"     # <-- AJUSTAR
region               = "us-central1"

# Generalmente, para QA se querría crear los recursos, así que se dejan en 'true'.
# Cámbialos a 'false' si la red compartida y el peering ya existen para QA.
create_service_project_attachment = false
create_service_networking_connection = false

subnet_names = ["subnet-external-1", "subnet-internal-1", "subnet-external-2"]
network_name = "vpc-qa-shared" # <-- AJUSTAR si es necesario

compute_instances = {
  "vm-external-1" = {
    name         = "vm-external-1"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-external-1"
    tags         = ["usuario=user1", "ambiente=qa"]
    external_ip  = true
  },
  "vm-external-2" = {
    name         = "vm-external-2"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-external-1"
    tags         = ["usuario=user1", "ambiente=qa"]
    external_ip  = true
  },
  "vm-internal-1" = {
    name         = "vm-internal-1"
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    subnet_name  = "subnet-internal-1"
    tags         = ["usuario=user2", "ambiente=qa"]
    external_ip  = false
  }
}

cloud_sql_instance_name    = "cloud-sql-instance-qa"
cloud_sql_database_version = "POSTGRES_13"
cloud_sql_tier             = "db-g1-small"
cloud_sql_zone             = "us-central1-b"
cloud_sql_psa_peering_range_name = "psa-googleservices-qa" # <-- AJUSTAR si es necesario
