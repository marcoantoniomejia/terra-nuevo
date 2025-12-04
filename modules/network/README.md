# Módulo de Red

Este módulo crea los recursos de red, incluida la conexión de VPC compartida y las subredes.

## Uso

```hcl
module "network" {
  source               = "../../modules/network"
  host_project_id      = "your-host-project-id"
  service_project_id   = "your-service-project-id"
  subnets = {
    "subnet-external-1" = {
      name          = "subnet-external-1"
      cidr          = "10.0.1.0/24"
      region        = "us-central1"
    },
    "subnet-internal-1" = {
      name          = "subnet-internal-1"
      cidr          = "10.0.2.0/24"
      region        = "us-central1"
      private_ip_google_access = false
    }
  }
}
```