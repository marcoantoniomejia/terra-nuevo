# Por favor, revisa y ajusta estos valores para que coincidan con tu ambiente de PRD.
# Los project_id se han asumido siguiendo el patrón de 'dev'.

host_project_id    = "vpc-host-prd-xxxxxx"  # <-- AJUSTAR
service_project_id   = "iwx-infra-01-prd"     # <-- AJUSTAR
region               = "us-central1"

# Para PRD, es muy probable que la red compartida y el peering ya existan.
# Si es así, mantenlos en 'false'. Cámbialos a 'true' solo si necesitas crearlos.
create_service_project_attachment = false
create_service_networking_connection = false

subnet_names = ["subnet-external-1", "subnet-internal-1", "subnet-external-2"]
network_name = "vpc-prd-shared" # <-- AJUSTAR si es necesario

compute_instances = {
  "vm-external-1" = {
    name         = "vm-external-1"
    machine_type = "e2-standard-2"
    zone         = "us-central1-b"
    subnet_name  = "subnet-external-1"
    tags         = ["usuario=user1", "ambiente=prd"]
    external_ip  = true
  },
  "vm-external-2" = {
    name         = "vm-external-2"
    machine_type = "e2-standard-2"
    zone         = "us-central1-b"
    subnet_name  = "subnet-external-1"
    tags         = ["usuario=user1", "ambiente=prd"]
    external_ip  = true
  },
  "vm-internal-1" = {
    name         = "vm-internal-1"
    machine_type = "e2-standard-2"
    zone         = "us-central1-b"
    subnet_name  = "subnet-internal-1"
    tags         = ["usuario=user2", "ambiente=prd"]
    external_ip  = false
  }
}

cloud_sql_instance_name    = "cloud-sql-instance-prd"
cloud_sql_database_version = "POSTGRES_13"
cloud_sql_tier             = "db-n1-standard-1"
cloud_sql_zone             = "us-central1-b"
cloud_sql_psa_peering_range_name = "psa-googleservices-prd" # <-- AJUSTAR si es necesario
