# Módulo Network

Este módulo gestiona la configuración de red en Google Cloud Platform, incluyendo la referencia a subredes existentes en una VPC compartida y la vinculación de proyectos de servicio.

## Descripción

El módulo `network` se utiliza para:

- Referenciar subredes existentes en un proyecto host (Shared VPC)
- Vincular proyectos de servicio a la VPC compartida
- Proporcionar información de red a otros módulos

## Características

- ✅ Soporte para Shared VPC
- ✅ Referencia a múltiples subredes existentes
- ✅ Vinculación condicional de proyectos de servicio
- ✅ Outputs para uso en otros módulos

## Uso

```hcl
module "network" {
  source = "../../modules/network"

  host_project_id                   = "vpc-host-project-id"
  service_project_id                = "service-project-id"
  subnet_names                      = ["subnet-1", "subnet-2"]
  region                            = "us-central1"
  network_name                      = "vpc-shared"
  create_service_project_attachment = true
}
```

## Variables de Entrada

| Nombre                              | Descripción                                                               | Tipo           | Requerido | Default |
| ----------------------------------- | ------------------------------------------------------------------------- | -------------- | --------- | ------- |
| `host_project_id`                   | ID del proyecto anfitrión donde se encuentra la VPC compartida            | `string`       | Sí        | -       |
| `service_project_id`                | ID del proyecto de servicio que se vinculará a la VPC                     | `string`       | Sí        | -       |
| `subnet_names`                      | Lista de nombres de subredes existentes a referenciar                     | `list(string)` | Sí        | -       |
| `region`                            | Región donde se encuentran las subredes                                   | `string`       | Sí        | -       |
| `network_name`                      | Nombre de la red VPC                                                      | `string`       | Sí        | -       |
| `create_service_project_attachment` | Flag para controlar la creación del attachment. Usar `false` si ya existe | `bool`         | No        | `true`  |

## Outputs

| Nombre              | Descripción                                         |
| ------------------- | --------------------------------------------------- |
| `subnets`           | Mapa de objetos de subredes con toda su información |
| `network_self_link` | Self-link de la red VPC para usar en otros recursos |

## Ejemplo Completo

```hcl
module "network" {
  source = "../../modules/network"

  host_project_id    = "vpc-host-dev-414119"
  service_project_id = "iwx-infra-01-dev"
  region             = "us-central1"
  network_name       = "vpc-dev-shared"

  subnet_names = [
    "subnet-dev01",
    "subnet-dev02"
  ]

  # Si el attachment ya existe, usar false
  create_service_project_attachment = false
}

# Usar outputs en otros módulos
module "compute" {
  source  = "../../modules/compute"
  subnets = module.network.subnets
  # ...
}
```

## Notas Importantes

### Shared VPC

Este módulo asume que estás usando **Shared VPC** en GCP. Esto significa:

- El proyecto host contiene la VPC y las subredes
- Los proyectos de servicio usan la red del proyecto host
- Se requieren permisos específicos de IAM

### Permisos Necesarios

Para usar este módulo, necesitas:

- `compute.networkUser` en las subredes del proyecto host
- `compute.sharedVpcAdmin` para crear el attachment (si aplica)

### Service Project Attachment

El flag `create_service_project_attachment` debe ser `false` si:

- El attachment ya fue creado previamente
- Estás re-aplicando la configuración
- Otro proceso ya vinculó el proyecto

## Dependencias

Este módulo no tiene dependencias de otros módulos, pero es típicamente usado por:

- `modules/compute` - Para obtener información de subredes
- `modules/cloud-sql` - Para configuración de red privada

## Versión de Terraform

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
```

## Recursos Creados

- `google_compute_shared_vpc_service_project` (condicional)

## Recursos Referenciados

- `google_compute_subnetwork` (data source)

## Troubleshooting

### Error: "Subnet not found"

**Causa**: La subred especificada no existe en el proyecto host.

**Solución**: Verifica que:

1. El nombre de la subred sea correcto
2. La región sea correcta
3. El proyecto host sea correcto

### Error: "Permission denied"

**Causa**: El Service Account no tiene permisos suficientes.

**Solución**: Asegúrate de tener el rol `compute.networkUser` en las subredes.

### Error: "Service project attachment already exists"

**Causa**: El proyecto ya está vinculado a la VPC compartida.

**Solución**: Usa `create_service_project_attachment = false`

## Mantenimiento

**Propietario**: Equipo de Infraestructura  
**Última actualización**: 2026-01-06
