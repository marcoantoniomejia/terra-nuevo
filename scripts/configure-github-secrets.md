# Configuración de GitHub Secrets para CI/CD

Esta guía te ayudará a configurar los secretos necesarios en GitHub para que los workflows de GitHub Actions puedan autenticarse con GCP.

## Prerequisitos

✅ Haber ejecutado el script `scripts/setup-gcp-auth.sh` para cada entorno (dev, qa, prd)

## Secretos a Configurar

### 1. Secretos a Nivel de Repositorio

Ve a tu repositorio en GitHub: `Settings > Secrets and variables > Actions > New repository secret`

#### Secreto: `GCP_WORKLOAD_IDENTITY_PROVIDER`

**Descripción**: Provider de Workload Identity Federation (compartido entre todos los entornos)

**Valor**: Lo obtendrás al ejecutar el script `setup-gcp-auth.sh`. Tiene el formato:

```
projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/providers/github-provider
```

**Pasos**:

1. Click en "New repository secret"
2. Name: `GCP_WORKLOAD_IDENTITY_PROVIDER`
3. Secret: Pega el valor del provider
4. Click "Add secret"

---

#### Secreto: `GCP_SERVICE_ACCOUNT_EMAIL_DEV`

**Descripción**: Email del Service Account para el entorno DEV

**Valor**:

```
github-actions-terraform-dev@iwx-infra-01-dev.iam.gserviceaccount.com
```

**Pasos**:

1. Click en "New repository secret"
2. Name: `GCP_SERVICE_ACCOUNT_EMAIL_DEV`
3. Secret: Pega el email del SA de dev
4. Click "Add secret"

---

#### Secreto: `GCP_SERVICE_ACCOUNT_EMAIL_QA`

**Descripción**: Email del Service Account para el entorno QA

**Valor**:

```
github-actions-terraform-qa@[PROJECT_ID_QA].iam.gserviceaccount.com
```

**Pasos**:

1. Click en "New repository secret"
2. Name: `GCP_SERVICE_ACCOUNT_EMAIL_QA`
3. Secret: Pega el email del SA de qa
4. Click "Add secret"

---

#### Secreto: `GCP_SERVICE_ACCOUNT_EMAIL_PRD`

**Descripción**: Email del Service Account para el entorno PRD

**Valor**:

```
github-actions-terraform-prd@[PROJECT_ID_PRD].iam.gserviceaccount.com
```

**Pasos**:

1. Click en "New repository secret"
2. Name: `GCP_SERVICE_ACCOUNT_EMAIL_PRD`
3. Secret: Pega el email del SA de prd
4. Click "Add secret"

---

### 2. Configurar Environments en GitHub

Para habilitar aprobaciones manuales en producción, debes crear environments:

#### Environment: `dev`

1. Ve a `Settings > Environments > New environment`
2. Name: `dev`
3. Click "Configure environment"
4. No requiere aprobadores (opcional)
5. Click "Save protection rules"

#### Environment: `qa`

1. Ve a `Settings > Environments > New environment`
2. Name: `qa`
3. Click "Configure environment"
4. (Opcional) Agrega required reviewers si deseas
5. Click "Save protection rules"

#### Environment: `prd`

1. Ve a `Settings > Environments > New environment`
2. Name: `prd`
3. Click "Configure environment"
4. ✅ **Marca "Required reviewers"**
5. Agrega los usuarios que deben aprobar despliegues a producción
6. (Opcional) Configura "Wait timer" para espera adicional
7. Click "Save protection rules"

#### Environment: `prd-destroy`

1. Ve a `Settings > Environments > New environment`
2. Name: `prd-destroy`
3. Click "Configure environment"
4. ✅ **Marca "Required reviewers"**
5. Agrega los usuarios que deben aprobar destrucción de producción
6. Click "Save protection rules"

---

## Verificación

### Verificar Secretos Configurados

1. Ve a `Settings > Secrets and variables > Actions`
2. Deberías ver:
   - ✅ `GCP_WORKLOAD_IDENTITY_PROVIDER`
   - ✅ `GCP_SERVICE_ACCOUNT_EMAIL_DEV`
   - ✅ `GCP_SERVICE_ACCOUNT_EMAIL_QA`
   - ✅ `GCP_SERVICE_ACCOUNT_EMAIL_PRD`

### Verificar Environments

1. Ve a `Settings > Environments`
2. Deberías ver:
   - ✅ `dev`
   - ✅ `qa`
   - ✅ `prd` (con required reviewers)
   - ✅ `prd-destroy` (con required reviewers)

---

## Protección de Rama Main

Para evitar pushes directos a main y forzar el uso de Pull Requests:

1. Ve a `Settings > Branches`
2. Click "Add branch protection rule"
3. Branch name pattern: `main`
4. Marca las siguientes opciones:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (mínimo 1)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - Agrega status checks requeridos:
     - `Validate Terraform Code`
     - `Plan - dev` (si aplica)
     - `Plan - qa` (si aplica)
     - `Plan - prd` (si aplica)
5. Click "Create"

---

## Troubleshooting

### Error: "Workload Identity Provider not found"

**Solución**: Verifica que el secreto `GCP_WORKLOAD_IDENTITY_PROVIDER` esté configurado correctamente y que el formato sea el correcto.

### Error: "Permission denied on service account"

**Solución**: Verifica que el Service Account tenga el rol `roles/iam.workloadIdentityUser` y que el binding esté configurado correctamente para tu repositorio.

### Error: "Failed to authenticate to Google Cloud"

**Solución**:

1. Verifica que las APIs necesarias estén habilitadas en GCP
2. Verifica que el Service Account exista
3. Verifica que el email del SA sea correcto en los secretos

---

## Siguiente Paso

Una vez configurados todos los secretos, puedes proceder a probar los workflows:

1. Crear una rama de prueba
2. Hacer un cambio en `environments/dev/terraform.tfvars`
3. Push y crear un PR
4. Verificar que el workflow de validación y plan se ejecuten correctamente
