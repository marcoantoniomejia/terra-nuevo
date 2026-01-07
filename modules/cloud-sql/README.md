# Módulo Cloud SQL

Este módulo gestiona la creación de instancias de Cloud SQL en Google Cloud Platform con conectividad privada mediante Private Service Access (PSA).

## Descripción

El módulo `cloud-sql` se utiliza para:

- Crear instancias de Cloud SQL (PostgreSQL, MySQL, SQL Server)
- Configurar conectividad privada con VPC mediante PSA
- Gestionar rangos de IP privadas para peering
- Habilitar Service Networking API automáticamente

## Características

- ✅ Soporte para múltiples motores de base de datos
- ✅ Conectividad privada (sin IP pública)
- ✅ Integración con Shared VPC
- ✅ Creación automática de rangos de peering
- ✅ Protección contra eliminación accidental
- ✅ Habilitación automática de APIs necesarias

## Uso Básico

```hcl
module "cloud_sql" {
  source                               = "../../modules/cloud-sql"
  project_id                           = "my-project-id"
  host_project_id                      = "vpc-host-project-id"
  instance_name                        = "my-database"
  database_version                     = "POSTGRES_13"
  tier                                 = "db-g1-small"
  zone                                 = "us-central1-a"
  network_self_link                    = module.network.network_self_link
  psa_peering_range_name               = "psa-range-db"
  create_service_networking_connection = true
}
```

## Variables de Entrada

| Nombre                                 | Descripción                                                  | Tipo     | Requerido | Default |
| -------------------------------------- | ------------------------------------------------------------ | -------- | --------- | ------- |
| `project_id`                           | ID del proyecto donde se creará Cloud SQL                    | `string` | Sí        | -       |
| `host_project_id`                      | ID del proyecto host con la VPC compartida                   | `string` | Sí        | -       |
| `instance_name`                        | Nombre de la instancia de Cloud SQL                          | `string` | Sí        | -       |
| `database_version`                     | Versión del motor de base de datos                           | `string` | Sí        | -       |
| `tier`                                 | Tipo de máquina para la instancia                            | `string` | Sí        | -       |
| `zone`                                 | Zona de GCP para la instancia                                | `string` | Sí        | -       |
| `network_self_link`                    | Self-link de la VPC                                          | `string` | Sí        | -       |
| `psa_peering_range_name`               | Nombre del rango de peering PSA. Si vacío, se crea uno nuevo | `string` | No        | `""`    |
| `create_service_networking_connection` | Flag para crear la conexión PSA. Usar `false` si ya existe   | `bool`   | No        | `true`  |

## Outputs

| Nombre               | Descripción                                  |
| -------------------- | -------------------------------------------- |
| `instance`           | Objeto completo de la instancia de Cloud SQL |
| `instance_name`      | Nombre de la instancia                       |
| `connection_name`    | Connection name para Cloud SQL Proxy         |
| `private_ip_address` | Dirección IP privada de la instancia         |

## Versiones de Base de Datos Soportadas

### PostgreSQL

- `POSTGRES_9_6`
- `POSTGRES_10`
- `POSTGRES_11`
- `POSTGRES_12`
- `POSTGRES_13`
- `POSTGRES_14`
- `POSTGRES_15`

### MySQL

- `MYSQL_5_6`
- `MYSQL_5_7`
- `MYSQL_8_0`

### SQL Server

- `SQLSERVER_2017_STANDARD`
- `SQLSERVER_2017_ENTERPRISE`
- `SQLSERVER_2019_STANDARD`
- `SQLSERVER_2019_ENTERPRISE`

## Tipos de Máquina (Tiers)

### Shared Core (Desarrollo/Testing)

| Tier          | vCPUs      | Memoria | Uso     |
| ------------- | ---------- | ------- | ------- |
| `db-f1-micro` | Compartido | 0.6 GB  | Testing |
| `db-g1-small` | Compartido | 1.7 GB  | Dev/QA  |

### Dedicated Core (Producción)

| Tier               | vCPUs | Memoria | Uso                     |
| ------------------ | ----- | ------- | ----------------------- |
| `db-n1-standard-1` | 1     | 3.75 GB | Pequeño                 |
| `db-n1-standard-2` | 2     | 7.5 GB  | Medio                   |
| `db-n1-standard-4` | 4     | 15 GB   | Grande                  |
| `db-n1-highmem-2`  | 2     | 13 GB   | Alto uso de memoria     |
| `db-n1-highmem-4`  | 4     | 26 GB   | Muy alto uso de memoria |

## Ejemplo Completo

```hcl
module "network" {
  source = "../../modules/network"
  # ... configuración de network
}

module "cloud_sql" {
  source            = "../../modules/cloud-sql"
  project_id        = "iwx-infra-01-dev"
  host_project_id   = "vpc-host-dev-414119"
  instance_name     = "postgres-dev-01"
  database_version  = "POSTGRES_14"
  tier              = "db-g1-small"
  zone              = "us-central1-a"
  network_self_link = module.network.network_self_link

  # Crear nuevo rango de peering
  psa_peering_range_name = ""

  # Crear conexión PSA (primera vez)
  create_service_networking_connection = true
}

# Outputs útiles
output "db_connection_name" {
  value = module.cloud_sql.connection_name
}

output "db_private_ip" {
  value     = module.cloud_sql.private_ip_address
  sensitive = true
}
```

## Private Service Access (PSA)

Este módulo configura conectividad privada mediante PSA:

### ¿Qué es PSA?

Private Service Access permite que Cloud SQL se conecte a tu VPC mediante IPs privadas, sin necesidad de IPs públicas.

### Componentes de PSA

1. **Rango de IP Privado**: Bloque CIDR reservado para servicios de Google
2. **Peering de VPC**: Conexión entre tu VPC y la VPC de Google
3. **Service Networking Connection**: Configuración del peering

### Configuración Inicial vs Subsecuente

#### Primera Instancia (Configuración Inicial)

```hcl
psa_peering_range_name               = ""      # Crear nuevo
create_service_networking_connection = true    # Crear conexión
```

#### Instancias Adicionales (Mismo Proyecto/VPC)

```hcl
psa_peering_range_name               = "psa-googleservices-dev"  # Usar existente
create_service_networking_connection = false                      # No recrear
```

## Rango de IP para PSA

El módulo crea automáticamente un rango `/20` (4,096 IPs) si no se especifica uno existente.

### Calcular Rango Necesario

- Cada instancia de Cloud SQL usa ~1-5 IPs
- Recomendado: `/20` para hasta ~800 instancias
- Mínimo: `/24` para hasta ~50 instancias

## Seguridad

### Protección contra Eliminación

El módulo incluye `prevent_destroy = true` para evitar eliminación accidental:

```hcl
lifecycle {
  prevent_destroy = true
}
```

Para eliminar una instancia:

1. Comentar o remover el bloque `lifecycle`
2. Ejecutar `terraform apply`
3. Eliminar el recurso

### Sin IP Pública

Por defecto, las instancias solo tienen IP privada:

```hcl
ip_configuration {
  ipv4_enabled    = false  # Sin IP pública
  private_network = var.network_self_link
}
```

## Conectividad

### Desde Compute Engine

Las instancias en la misma VPC pueden conectarse directamente usando la IP privada:

```bash
psql -h 10.x.x.x -U postgres -d mydb
```

### Desde Cloud SQL Proxy

Para conexiones desde fuera de GCP:

```bash
cloud_sql_proxy -instances=PROJECT:REGION:INSTANCE=tcp:5432
psql -h 127.0.0.1 -U postgres -d mydb
```

## Permisos Necesarios

El Service Account necesita:

- `cloudsql.instances.create`
- `cloudsql.instances.get`
- `compute.addresses.create`
- `servicenetworking.services.addPeering`

Roles recomendados:

- `roles/cloudsql.admin`
- `roles/compute.networkAdmin` (en proyecto host)

## Dependencias

Este módulo depende de:

- `modules/network` - Para obtener el network self-link

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

- `google_sql_database_instance` - Instancia de Cloud SQL
- `google_project_service` - Habilita Service Networking API
- `google_compute_global_address` - Rango de IP para PSA (condicional)
- `google_service_networking_connection` - Conexión PSA (condicional)

## Troubleshooting

### Error: "Service Networking API not enabled"

**Causa**: La API no está habilitada.

**Solución**: El módulo la habilita automáticamente, pero puede tardar unos minutos. Espera y reintenta.

### Error: "IP range overlaps with existing range"

**Causa**: El rango de IP para PSA se solapa con subredes existentes.

**Solución**: Usa un rango diferente que no se solape con tu VPC.

### Error: "Service Networking Connection already exists"

**Causa**: Ya existe una conexión PSA para esta VPC.

**Solución**: Usa `create_service_networking_connection = false`

### No puedo conectarme a la base de datos

**Causas posibles**:

1. Firewall bloqueando tráfico
2. Instancia de Compute no en la misma VPC
3. Credenciales incorrectas

**Solución**:

1. Verifica reglas de firewall
2. Confirma que ambos recursos están en la misma VPC
3. Verifica usuario y contraseña

### Error: "Cannot destroy instance"

**Causa**: `prevent_destroy = true` está activo.

**Solución**: Ver sección de Seguridad arriba.

## Mejoras Futuras

- [ ] Soporte para réplicas de lectura
- [ ] Configuración de backups automáticos
- [ ] Flags de base de datos personalizados
- [ ] Configuración de mantenimiento
- [ ] Usuarios y bases de datos adicionales
- [ ] Integración con Secret Manager para credenciales

## Mantenimiento

**Propietario**: Equipo de Infraestructura  
**Última actualización**: 2026-01-06
