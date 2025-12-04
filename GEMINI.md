Directrices y Rol de Gemini Code Assist (GCA)
Rol de Agente y Ejecución
Modo Agente: Cuando se abordan tareas complejas, GCA operará en Modo Agente. Esto significa que primero analizará el problema, luego propondrá una solución multifacética y, con la aprobación del usuario, ejecutará cada paso de manera secuencial.

Modo de Planificación Estricto: GCA no ejecutará terraform apply o cualquier comando que modifique la infraestructura sin una instrucción explícita o una aprobación previa del plan generado. Siempre comenzará con terraform plan y esperará la confirmación, similar a un ingeniero senior que presenta una estrategia antes de actuar. 🧠

Seguridad (Shift Left Security)
GCA prioriza la seguridad en todas las etapas del ciclo de vida del código (Shift Left). Se debe usar terraform fmt, TFLint, y herramientas de escaneo de seguridad como Checkov o Terrascan para validar el código antes de la fusión. También se usará gcloud terraform vet para la validación de políticas.

Acceso a credenciales: GCA debe evitar estrictamente la descarga de claves de cuentas de servicio. En su lugar, debe heredar las credenciales directamente del entorno de ejecución de CI/CD (GitHub Actions) para la autenticación en GCP.

Estructura del Proyecto y Reglas de Terraform
Aislamiento de Entornos: Los entornos de desarrollo (dev), control de calidad (qa) y producción (prd) están estrictamente separados en directorios dedicados (environments/dev, environments/qa, environments/prd).

GCA tiene prohibido sugerir o usar terraform workspace para el aislamiento de entornos. El aislamiento del estado se gestiona a nivel de directorio, donde cada uno tiene su propio backend de Cloud Storage. 🚫

## Estructura de Directorios Estándar

Para mantener la consistencia y la claridad en los proyectos de Terraform, se debe seguir la siguiente estructura de directorios. Esta estructura promueve la separación de responsabilidades y el aislamiento de entornos.

```
.
├── bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── entorno-1.tfvars
│
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── qa/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   └── prd/
│       ├── main.tf
│       ├── variables.tf
│       ├── backend.tf
│       └── terraform.tfvars
│
├── modules/
│   ├── mi-modulo-1/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── mi-modulo-2/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
│
├── .gitignore
└── README.md
```

### Descripción de Directorios Clave

-   **`/bootstrap`**:
    -   **Propósito**: Contiene la configuración de Terraform para crear los recursos fundamentales que la propia infraestructura necesita para funcionar, principalmente el **bucket de GCS para el backend remoto**.
    -   **Backend**: Utiliza un backend `local` ya que se ejecuta antes de que exista el backend remoto.
    -   **Variables**: Se alimenta de archivos `.tfvars` específicos por entorno (ej. `dev.tfvars`) para crear un bucket por cada uno.

-   **`/environments`**:
    -   **Propósito**: Es el corazón del proyecto. Contiene un subdirectorio por cada entorno de despliegue (`dev`, `qa`, `prd`).
    -   **Aislamiento**: Cada subdirectorio es una configuración raíz de Terraform completamente aislada, con su propio estado.
    -   **Backend**: Cada entorno debe tener un archivo `backend.tf` que apunte al bucket de GCS correspondiente creado por la fase de `bootstrap`.
    -   **Variables**: La configuración de cada entorno se gestiona a través de su propio archivo `terraform.tfvars`.

-   **`/modules`**:
    -   **Propósito**: Contiene todos los módulos de Terraform reutilizables. Cada módulo debe ser una unidad lógica y autónoma de infraestructura (ej. un clúster de GKE, una red VPC, una base de datos).
    -   **Estándares**: Cada módulo debe tener su propio `README.md` documentando su uso, variables y salidas, además de un archivo `OWNERS` para definir la propiedad.

Archivos HCL Estándar:

Las variables se declaran exclusivamente en variables.tf.

Las salidas (outputs) se organizan en outputs.tf.

Los recursos se agrupan lógicamente en archivos HCL dedicados (ej., network.tf o instances.tf).

Nomenclatura y Estilo:

Los nombres de variables que representen valores numéricos deben incluir unidades (ej., ram_size_gb, disk_size_gb).

GCA debe usar el formato estándar de Terraform (terraform fmt) para mantener la consistencia.

Se debe evitar la redundancia en los nombres de los recursos. Por ejemplo, se debe usar google_compute_address.main en lugar de google_compute_address.main_global_address.

Gestión del Estado y Seguridad
Backend Remoto Obligatorio: El estado de Terraform debe ser almacenado en un bucket de Cloud Storage (GCS) remoto para permitir el bloqueo de estado y la colaboración en equipo. El bucket inicial se configura en el directorio bootstrap/.

Protección de Recursos Sensibles: Para evitar la eliminación accidental de recursos críticos, GCA debe sugerir la adición de prevent_destroy = true dentro del bloque lifecycle de recursos como bases de datos o discos persistentes. 🛡️

Versionamiento de Estado: El bucket de estado remoto debe tener la gestión de versiones de objetos habilitada para un historial de implementaciones.

Seguridad del Estado: El estado es un dato sensible y debe estar separado del control de versiones. El acceso al bucket de estado debe ser limitado solo a las cuentas de servicio de CI/CD y a los administradores de infraestructura.

Prácticas de Módulos Reutilizables
Activación de API: Los módulos deben activar los servicios de GCP necesarios (ej., Logging, Monitoring) mediante el recurso google_project_service para asegurar que las dependencias estén satisfechas.

Manejo de Dependencias y Versiones: Los módulos no deben configurar proveedores o backends; esta tarea es exclusiva de los módulos raíz en cada entorno. Las referencias a módulos deben utilizar restricciones de versión, bloqueando la versión principal (ej., version = "~> 1.2.0").

Propiedad del Código: Todos los módulos compartidos en modules/ deben incluir un archivo OWNERS o CODEOWNERS para dejar clara la propiedad y responsabilidad del mantenimiento.di