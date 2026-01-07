# Guía de Contribución

¡Gracias por contribuir a este proyecto de infraestructura! Esta guía te ayudará a entender el proceso de desarrollo y las mejores prácticas.

## 📋 Tabla de Contenidos

- [Flujo de Trabajo](#flujo-de-trabajo)
- [Estándares de Código](#estándares-de-código)
- [Proceso de Branching](#proceso-de-branching)
- [Testing Local](#testing-local)
- [Creación de Pull Requests](#creación-de-pull-requests)

---

## 🔄 Flujo de Trabajo

### 1. Crear una Rama

```bash
# Actualizar main
git checkout main
git pull origin main

# Crear rama feature
git checkout -b feature/descripcion-del-cambio

# O rama de fix
git checkout -b fix/descripcion-del-problema
```

### 2. Hacer Cambios

- Edita los archivos de Terraform necesarios
- Sigue los estándares de código (ver abajo)
- Prueba localmente antes de hacer commit

### 3. Commit y Push

```bash
# Formatear código
terraform fmt -recursive

# Agregar cambios
git add .

# Commit con mensaje descriptivo
git commit -m "feat(dev): agregar nueva instancia de compute"

# Push a tu rama
git push origin feature/descripcion-del-cambio
```

### 4. Crear Pull Request

- Ve a GitHub y crea un PR desde tu rama hacia `main`
- Completa el template del PR
- Espera a que los checks automáticos pasen
- Solicita revisión de un compañero

### 5. Revisión y Merge

- Revisa los comentarios del plan de Terraform
- Realiza cambios si son necesarios
- Una vez aprobado, haz merge a `main`
- El workflow automáticamente aplicará los cambios

---

## 📝 Estándares de Código

### Formato

**Siempre** ejecuta `terraform fmt -recursive` antes de hacer commit:

```bash
terraform fmt -recursive
```

### Nomenclatura

#### Variables

```hcl
# ✅ Correcto - snake_case con unidades
variable "disk_size_gb" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 100
}

# ❌ Incorrecto
variable "diskSize" {
  type = number
}
```

#### Recursos

```hcl
# ✅ Correcto - nombre descriptivo sin redundancia
resource "google_compute_instance" "web_server" {
  name = "web-server-${var.environment}"
}

# ❌ Incorrecto - redundante
resource "google_compute_instance" "compute_instance_web_server" {
  name = "instance"
}
```

### Documentación

Todas las variables deben tener descripción:

```hcl
variable "project_id" {
  description = "El ID del proyecto de GCP donde se crearán los recursos"
  type        = string
}
```

### Validaciones

Agrega validaciones para variables críticas:

```hcl
variable "environment" {
  description = "Entorno de despliegue"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prd"], var.environment)
    error_message = "El entorno debe ser dev, qa o prd"
  }
}
```

---

## 🌿 Proceso de Branching

Usamos **GitFlow simplificado**:

### Tipos de Ramas

#### `main`

- Rama protegida
- Solo se actualiza mediante PRs
- Representa el estado actual de la infraestructura
- Los merges a main disparan deployments automáticos

#### `feature/*`

- Para nuevas funcionalidades o recursos
- Ejemplo: `feature/add-cloud-sql-replica`

#### `fix/*`

- Para correcciones de bugs
- Ejemplo: `fix/network-subnet-cidr`

#### `refactor/*`

- Para refactorización de código
- Ejemplo: `refactor/compute-module-structure`

### Convención de Nombres

```
tipo/descripcion-corta

Ejemplos:
- feature/add-monitoring-dashboard
- fix/firewall-rule-priority
- refactor/network-module
```

---

## 🧪 Testing Local

Antes de crear un PR, **siempre** prueba localmente:

### 1. Validación Básica

```bash
# Ir al directorio del entorno
cd environments/dev

# Inicializar (si es necesario)
terraform init

# Formatear
terraform fmt

# Validar sintaxis
terraform validate
```

### 2. Plan

```bash
# Generar plan
terraform plan

# Revisar cuidadosamente el output
# Verifica que los cambios sean los esperados
```

### 3. TFLint (Opcional pero recomendado)

```bash
# Instalar tflint si no lo tienes
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Inicializar
tflint --init

# Ejecutar
tflint
```

### 4. Checkov (Seguridad)

```bash
# Instalar checkov
pip install checkov

# Ejecutar desde la raíz del proyecto
checkov -d . --framework terraform
```

---

## 🔍 Creación de Pull Requests

### Checklist Pre-PR

Antes de crear tu PR, verifica:

- [ ] ✅ Ejecuté `terraform fmt -recursive`
- [ ] ✅ Ejecuté `terraform validate` sin errores
- [ ] ✅ Revisé el `terraform plan` localmente
- [ ] ✅ Actualicé documentación si fue necesario
- [ ] ✅ No incluí credenciales o información sensible
- [ ] ✅ Los nombres siguen las convenciones
- [ ] ✅ Agregué descripciones a las variables nuevas

### Título del PR

Usa el formato:

```
tipo(entorno): descripción breve

Ejemplos:
- feat(dev): agregar instancia de Cloud SQL
- fix(prd): corregir regla de firewall
- refactor(all): mejorar módulo de network
```

### Descripción del PR

Usa el template proporcionado y completa todas las secciones:

- Descripción clara de los cambios
- Entornos afectados
- Tipo de cambio
- Checklist de validación
- Impacto en costos

### Revisión del Plan

Cuando crees el PR, GitHub Actions automáticamente:

1. ✅ Validará el formato y sintaxis
2. 📋 Generará el plan de Terraform
3. 💬 Comentará el plan en el PR

**Revisa cuidadosamente el plan** antes de aprobar el merge.

### Aprobación

- Los PRs requieren al menos 1 aprobación
- Para cambios en `prd`, se requiere aprobación de un admin
- Todos los checks deben pasar antes de hacer merge

---

## 🚀 Después del Merge

Una vez que tu PR sea aprobado y hagas merge:

1. GitHub Actions automáticamente ejecutará `terraform apply`
2. Los cambios se aplicarán en el orden: dev → qa → prd
3. Para `prd`, se requerirá aprobación manual adicional
4. Recibirás notificaciones del resultado

### Monitoreo

Después del deployment:

1. Verifica en GCP Console que los recursos se crearon correctamente
2. Revisa los logs del workflow en GitHub Actions
3. Verifica que el estado se guardó en el bucket de GCS

---

## ❓ Preguntas Frecuentes

### ¿Puedo hacer push directo a main?

**No.** La rama `main` está protegida. Todos los cambios deben pasar por un PR.

### ¿Qué hago si el plan muestra cambios inesperados?

1. Revisa cuidadosamente qué está cambiando
2. Si no estás seguro, pide ayuda en el PR
3. No hagas merge hasta entender todos los cambios

### ¿Cómo pruebo cambios sin afectar infraestructura real?

Usa el entorno `dev` para pruebas. Los cambios se aplicarán primero ahí.

### ¿Qué hago si terraform apply falla?

1. Revisa los logs en GitHub Actions
2. Verifica el estado en GCS
3. Si es necesario, ejecuta `terraform refresh` localmente
4. Crea un PR con la corrección

---

## 📞 Contacto

Si tienes preguntas o necesitas ayuda, contacta al equipo de infraestructura.

---

**¡Gracias por contribuir! 🎉**
