# Proyecto de Terraform

Este proyecto contiene los scripts de Terraform para crear la infraestructura en Google Cloud Platform.

## Estructura del Proyecto

El proyecto está estructurado de la siguiente manera:

-   `bootstrap/`: Contiene los scripts para crear el bucket de GCS para el estado remoto de Terraform.
-   `environments/`: Contiene la configuración para cada entorno (`dev`, `qa`, `prd`).
    -   `dev/`: Configuración para el entorno de desarrollo.
    -   `qa/`: Configuración para el entorno de aseguramiento de la calidad.
    -   `prd/`: Configuración para el entorno de producción.
-   `modules/`: Contiene los módulos reutilizables de Terraform.
    -   `network/`: Módulo para los recursos de red (VPC, subredes).
    -   `compute/`: Módulo para las instancias de Compute Engine.
    -   `cloud-sql/`: Módulo para las instancias de Cloud SQL.

## Cómo usar

### 1. Bootstrap

El primer paso es crear el bucket de GCS para almacenar el estado de Terraform.

Navega al directorio `bootstrap`:

```bash
cd bootstrap
```

Inicializa Terraform:

```bash
terraform init
```

Crea un archivo `.tfvars` para el entorno que deseas crear. Por ejemplo, para el entorno `dev`, crea un archivo `dev.tfvars` con el siguiente contenido:

```hcl
bucket_name = "tu-nombre-de-bucket-gcs-dev"
project_id  = "tu-id-de-proyecto-gcp"
location    = "US"
```

Aplica la configuración:

```bash
terraform apply -var-file="dev.tfvars"
```

### 2. Desplegar un entorno

Una vez que se ha creado el bucket de GCS, puedes desplegar un entorno.

Navega al directorio del entorno, por ejemplo `dev`:

```bash
cd environments/dev
```

Actualiza el archivo `backend.tf` con el nombre del bucket de GCS creado en la fase de bootstrap.

Inicializa Terraform:

```bash
terraform init
```

Actualiza el archivo `terraform.tfvars` con los valores requeridos.

Aplica la configuración:

```bash
terraform apply
```