# Módulo de Cómputo

Este módulo crea instancias de Compute Engine.

## Uso

```hcl
module "compute" {
  source     = "../../modules/compute"
  project_id = "your-project-id"
  subnets    = module.network.subnets
  instances = {
    "vm-1" = {
      name         = "vm-1"
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      subnet_name  = "subnet-external-1"
      tags         = ["usuario=user1", "ambiente=dev"]
      external_ip  = true
    }
  }
}
```