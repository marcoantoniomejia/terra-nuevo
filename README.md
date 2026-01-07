# Proyecto de Infraestructura Terraform en GCP

Este proyecto contiene la infraestructura como código (IaC) para gestionar recursos en Google Cloud Platform usando Terraform, con CI/CD automatizado mediante GitHub Actions.

## 🚀 Características

- ✅ **CI/CD Automatizado** con GitHub Actions
- ✅ **Múltiples Entornos** (dev, qa, prd) completamente aislados
- ✅ **Seguridad Shift-Left** con validación automática y escaneo de seguridad
- ✅ **Workload Identity Federation** para autenticación sin claves
- ✅ **Módulos Reutilizables** para network, compute y cloud-sql
- ✅ **Estado Remoto** en Google Cloud Storage con versionamiento
- ✅ **Protección de Producción** con aprobaciones manuales

## 📁 Estructura del Proyecto

```
.
├── .github/
│   ├── workflows/
│   │   ├── terraform-validate.yml    # Validación automática
│   │   ├── terraform-plan.yml        # Plan en PRs
│   │   ├── terraform-apply.yml       # Apply en merge
│   │   └── terraform-destroy.yml     # Destroy manual
│   └── PULL_REQUEST_TEMPLATE.md
│
├── bootstrap/                         # Configuración inicial
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── dev.tfvars
│   └── prd.tfvars
│
├── environments/                      # Configuración por entorno
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── qa/
│   └── prd/
│
├── modules/                           # Módulos reutilizables
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   └── cloud-sql/
│
├── scripts/
│   ├── setup-gcp-auth.sh             # Setup de Workload Identity
│   └── configure-github-secrets.md   # Guía de configuración
│
├── .terraform-version                 # Versión de Terraform
├── .tflint.hcl                       # Configuración de TFLint
├── .checkov.yml                      # Configuración de Checkov
├── CONTRIBUTING.md                   # Guía de contribución
└── README.md                         # Este archivo
```

## 🔄 Flujo de Trabajo CI/CD

### 1. Desarrollo Local

```bash
# Crear rama feature
git checkout -b feature/nueva-funcionalidad

# Hacer cambios en Terraform
cd environments/dev
vim terraform.tfvars

# Validar localmente
terraform fmt -recursive
terraform validate
terraform plan

# Commit y push
git add .
git commit -m "feat(dev): agregar nueva instancia"
git push origin feature/nueva-funcionalidad
```

### 2. Pull Request

Al crear un PR hacia `main`:

1. ✅ **Validación Automática** (`terraform-validate.yml`)

   - Formato de código
   - Sintaxis de Terraform
   - TFLint (mejores prácticas)
   - Checkov (seguridad)

2. 📋 **Plan Automático** (`terraform-plan.yml`)

   - Detecta entornos modificados
   - Genera plan de Terraform
   - Comenta el plan en el PR

3. 👀 **Revisión Manual**
   - Revisar el plan comentado
   - Aprobar cambios
   - Hacer merge

### 3. Deployment Automático

Al hacer merge a `main`:

1. 🚀 **Apply Automático** (`terraform-apply.yml`)

   - Aplica cambios en orden: dev → qa → prd
   - Requiere aprobación manual para `prd`
   - Actualiza estado en GCS

2. ✅ **Verificación**
   - Verifica recursos en GCP Console
   - Revisa logs en GitHub Actions

## 🛠️ Configuración Inicial

### Prerequisitos

- Cuenta de GCP con permisos de administrador
- Repositorio en GitHub
- `gcloud` CLI instalado
- Terraform 1.6.6+

### Paso 1: Bootstrap (Crear Buckets de Estado)

```bash
cd bootstrap

# Para dev
terraform init
terraform apply -var-file="dev.tfvars"

# Para prd (repetir para cada entorno)
terraform apply -var-file="prd.tfvars"
```

### Paso 2: Configurar Workload Identity Federation

```bash
# Ejecutar para cada entorno
./scripts/setup-gcp-auth.sh

# Seguir las instrucciones en pantalla
# Guardar los valores generados
```

### Paso 3: Configurar GitHub Secrets

Sigue la guía en `scripts/configure-github-secrets.md` para:

1. Agregar secretos en GitHub
2. Configurar environments
3. Configurar protección de rama `main`

### Paso 4: Primer Deployment

```bash
# Actualizar backend.tf con el bucket creado
cd environments/dev
vim backend.tf

# Inicializar y aplicar
terraform init
terraform apply
```

## 📚 Uso de Módulos

### Módulo Network

```hcl
module "network" {
  source = "../../modules/network"

  host_project_id    = "vpc-host-project"
  service_project_id = "service-project"
  subnet_names       = ["subnet-1"]
  region             = "us-central1"
  network_name       = "vpc-shared"
}
```

Ver [modules/network/README.md](modules/network/README.md) para más detalles.

### Módulo Compute

```hcl
module "compute" {
  source     = "../../modules/compute"
  project_id = "my-project"
  subnets    = module.network.subnets

  instances = {
    "web-1" = {
      name         = "web-server-1"
      machine_type = "e2-medium"
      zone         = "us-central1-a"
      subnet_name  = "subnet-1"
      tags         = ["web"]
      external_ip  = true
    }
  }
}
```

Ver [modules/compute/README.md](modules/compute/README.md) para más detalles.

### Módulo Cloud SQL

```hcl
module "cloud_sql" {
  source            = "../../modules/cloud-sql"
  project_id        = "my-project"
  host_project_id   = "vpc-host-project"
  instance_name     = "postgres-db"
  database_version  = "POSTGRES_14"
  tier              = "db-g1-small"
  zone              = "us-central1-a"
  network_self_link = module.network.network_self_link
}
```

Ver [modules/cloud-sql/README.md](modules/cloud-sql/README.md) para más detalles.

## 🔐 Seguridad

### Workload Identity Federation

Este proyecto usa **Workload Identity Federation** en lugar de claves de Service Account:

- ✅ Sin claves estáticas descargadas
- ✅ Rotación automática de credenciales
- ✅ Permisos granulares por entorno
- ✅ Auditoría completa en GCP

### Validación Automática

Cada cambio pasa por:

- **TFLint**: Mejores prácticas de Terraform
- **Checkov**: Escaneo de seguridad
- **Terraform Validate**: Validación de sintaxis
- **Terraform Plan**: Revisión de cambios

### Protección de Producción

- Aprobación manual requerida para `prd`
- Rama `main` protegida (solo PRs)
- Estado remoto con versionamiento
- `prevent_destroy` en recursos críticos

## 🤝 Contribuir

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para:

- Estándares de código
- Proceso de branching
- Cómo crear PRs
- Testing local

## 📖 Workflows de GitHub Actions

### terraform-validate.yml

**Trigger**: Push a cualquier rama, PRs

**Acciones**:

- Formato de código
- Validación de sintaxis
- TFLint
- Checkov

### terraform-plan.yml

**Trigger**: PRs a `main`

**Acciones**:

- Detecta entornos modificados
- Genera plan de Terraform
- Comenta plan en PR

### terraform-apply.yml

**Trigger**: Push a `main` (después de merge)

**Acciones**:

- Aplica cambios en orden (dev → qa → prd)
- Requiere aprobación manual para `prd`
- Actualiza estado remoto

### terraform-destroy.yml

**Trigger**: Manual únicamente

**Acciones**:

- Destruye infraestructura de un entorno
- Requiere confirmación
- Doble aprobación para `prd`

## 🐛 Troubleshooting

### Error: "Workload Identity Provider not found"

Verifica que el secreto `GCP_WORKLOAD_IDENTITY_PROVIDER` esté configurado correctamente en GitHub.

### Error: "Permission denied"

Verifica que el Service Account tenga los permisos necesarios en GCP.

### Error: "Backend initialization failed"

Verifica que el bucket de estado exista y que tengas permisos de acceso.

### Plan muestra cambios inesperados

1. Revisa el plan cuidadosamente
2. Compara con el estado actual en GCP
3. Ejecuta `terraform refresh` localmente si es necesario

## 📞 Soporte

Para preguntas o problemas:

1. Revisa la documentación de los módulos
2. Busca en Issues de GitHub
3. Contacta al equipo de infraestructura

## 📝 Licencia

Este proyecto es privado y de uso interno.

## 🎯 Roadmap

- [ ] Agregar módulo para Cloud Run
- [ ] Implementar módulo para GKE
- [ ] Agregar tests automatizados con Terratest
- [ ] Implementar cost estimation en PRs
- [ ] Agregar notificaciones a Slack

---

**Última actualización**: 2026-01-06  
**Versión de Terraform**: 1.6.6  
**Mantenido por**: Equipo de Infraestructura
