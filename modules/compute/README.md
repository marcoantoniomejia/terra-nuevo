# Módulo Compute

Este módulo gestiona la creación de instancias de Compute Engine en Google Cloud Platform.

## Descripción

El módulo `compute` se utiliza para:

- Crear múltiples instancias de Compute Engine
- Configurar networking con subredes de Shared VPC
- Gestionar IPs externas opcionales
- Aplicar tags de red para reglas de firewall

## Características

- ✅ Creación de múltiples instancias mediante bucle `for_each`
- ✅ Soporte para IPs externas opcionales
- ✅ Integración con Shared VPC
- ✅ Configuración de tags de red
- ✅ Lifecycle policy para recreación segura

## Uso Básico

```hcl
module "compute" {
  source     = "../../modules/compute"
  project_id = "my-project-id"
  subnets    = module.network.subnets

  instances = {
    "web-server-1" = {
      name         = "web-server-1"
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      subnet_name  = "subnet-web"
      tags         = ["web", "http-server"]
      external_ip  = true
    }
  }
}
```

## Variables de Entrada

| Nombre       | Descripción                                         | Tipo          | Requerido | Default |
| ------------ | --------------------------------------------------- | ------------- | --------- | ------- |
| `project_id` | ID del proyecto donde se crearán las instancias     | `string`      | Sí        | -       |
| `subnets`    | Mapa de subredes (típicamente desde módulo network) | `any`         | Sí        | -       |
| `instances`  | Mapa de configuraciones de instancias               | `map(object)` | Sí        | -       |

### Estructura de `instances`

Cada instancia en el mapa debe tener:

```hcl
{
  name         = string        # Nombre de la instancia
  machine_type = string        # Tipo de máquina (e2-medium, n1-standard-1, etc.)
  zone         = string        # Zona de GCP (us-central1-a, etc.)
  subnet_name  = string        # Nombre de la subred (debe existir en var.subnets)
  tags         = list(string)  # Tags de red para firewall
  external_ip  = bool          # true para asignar IP externa, false para solo interna
}
```

## Outputs

| Nombre                | Descripción                                   |
| --------------------- | --------------------------------------------- |
| `instances`           | Mapa completo de todas las instancias creadas |
| `instance_ids`        | IDs de las instancias                         |
| `instance_self_links` | Self-links de las instancias                  |

## Ejemplo Completo

```hcl
module "network" {
  source = "../../modules/network"
  # ... configuración de network
}

module "compute" {
  source     = "../../modules/compute"
  project_id = "iwx-infra-01-dev"
  subnets    = module.network.subnets

  instances = {
    "app-server-1" = {
      name         = "app-server-1"
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      subnet_name  = "subnet-dev01"
      tags         = ["app", "backend"]
      external_ip  = false  # Solo IP interna
    },
    "app-server-2" = {
      name         = "app-server-2"
      machine_type = "e2-medium"
      zone         = "us-central1-b"
      subnet_name  = "subnet-dev01"
      tags         = ["app", "backend"]
      external_ip  = false
    },
    "bastion" = {
      name         = "bastion-host"
      machine_type = "e2-micro"
      zone         = "us-central1-a"
      subnet_name  = "subnet-dev01"
      tags         = ["bastion", "ssh"]
      external_ip  = true  # IP externa para acceso SSH
    }
  }
}

# Usar outputs
output "app_servers" {
  value = module.compute.instances
}
```

## Configuración de Imagen

Por defecto, todas las instancias usan:

- **Imagen**: `debian-cloud/debian-11`
- **Disco**: Tamaño por defecto de la imagen

Para cambiar la imagen, modifica `modules/compute/main.tf`:

```hcl
boot_disk {
  initialize_params {
    image = "ubuntu-os-cloud/ubuntu-2004-lts"  # Cambiar aquí
  }
}
```

## Tipos de Máquina Comunes

| Tipo            | vCPUs  | Memoria | Uso Recomendado              |
| --------------- | ------ | ------- | ---------------------------- |
| `e2-micro`      | 0.25-2 | 1 GB    | Bastion, testing             |
| `e2-small`      | 0.5-2  | 2 GB    | Servicios ligeros            |
| `e2-medium`     | 1-2    | 4 GB    | Aplicaciones estándar        |
| `e2-standard-2` | 2      | 8 GB    | Aplicaciones con carga media |
| `n1-standard-4` | 4      | 15 GB   | Aplicaciones con alta carga  |

## Zonas Disponibles

Para `us-central1`:

- `us-central1-a`
- `us-central1-b`
- `us-central1-c`
- `us-central1-f`

## Tags de Red

Los tags se usan para aplicar reglas de firewall. Ejemplos comunes:

```hcl
tags = ["web", "http-server", "https-server"]  # Servidor web
tags = ["db", "internal"]                       # Base de datos
tags = ["bastion", "ssh"]                       # Bastion host
tags = ["app", "backend"]                       # Servidor de aplicación
```

## IP Externa vs Interna

### IP Externa (`external_ip = true`)

- ✅ Accesible desde Internet
- ✅ Útil para bastions, NAT instances
- ⚠️ Mayor costo
- ⚠️ Mayor superficie de ataque

### Solo IP Interna (`external_ip = false`)

- ✅ Más seguro
- ✅ Menor costo
- ✅ Recomendado para servidores de aplicación y BD
- ⚠️ Requiere Cloud NAT para acceso a Internet saliente

## Lifecycle Policy

El módulo incluye `create_before_destroy = true` para:

- Minimizar downtime durante actualizaciones
- Crear nueva instancia antes de destruir la antigua
- Útil para rolling updates

## Permisos Necesarios

Para usar este módulo, el Service Account necesita:

- `compute.instances.create`
- `compute.instances.delete`
- `compute.instances.get`
- `compute.subnetworks.use`
- `compute.subnetworks.useExternalIp` (si `external_ip = true`)

Rol recomendado: `roles/compute.instanceAdmin.v1`

## Dependencias

Este módulo depende de:

- `modules/network` - Para obtener información de subredes

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

- `google_compute_instance` - Una por cada entrada en `var.instances`

## Troubleshooting

### Error: "Subnet not found"

**Causa**: El `subnet_name` especificado no existe en `var.subnets`.

**Solución**: Verifica que el nombre coincida exactamente con las subredes del módulo network.

### Error: "Quota exceeded"

**Causa**: Has alcanzado el límite de instancias o CPUs en tu proyecto.

**Solución**:

1. Elimina instancias no usadas
2. Solicita aumento de cuota en GCP Console

### Error: "Permission denied"

**Causa**: El Service Account no tiene permisos suficientes.

**Solución**: Asigna el rol `roles/compute.instanceAdmin.v1`

### Instancia no accesible desde Internet

**Causa**: Falta regla de firewall o `external_ip = false`.

**Solución**:

1. Verifica que `external_ip = true`
2. Crea regla de firewall para los tags de la instancia
3. Verifica que los tags estén aplicados correctamente

## Mejoras Futuras

Posibles mejoras a este módulo:

- [ ] Soporte para discos adicionales
- [ ] Configuración de tamaño de disco boot
- [ ] Metadata y startup scripts
- [ ] Service accounts personalizados por instancia
- [ ] Soporte para instance templates y managed instance groups

## Mantenimiento

**Propietario**: Equipo de Infraestructura  
**Última actualización**: 2026-01-06
