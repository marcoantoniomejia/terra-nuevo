# Módulo de Cloud SQL

Este módulo crea una instancia de Cloud SQL.

## Uso

```hcl
module "cloud_sql" {
  source           = "../../modules/cloud-sql"
  project_id       = "your-project-id"
  instance_name    = "cloud-sql-instance-1"
  database_version = "POSTGRES_13"
  tier             = "db-g1-small"
  zone             = "us-central1-b"
  subnet_name      = "subnet-external-2"
  subnets          = module.network.subnets
}
```