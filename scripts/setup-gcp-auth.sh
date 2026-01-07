#!/bin/bash

# Script para configurar Workload Identity Federation para GitHub Actions
# Este script debe ejecutarse con permisos de administrador en GCP

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configuración de Workload Identity Federation para GitHub Actions ===${NC}\n"

# Solicitar información
read -p "Ingresa el ID del proyecto GCP (ej: iwx-infra-01-dev): " PROJECT_ID
read -p "Ingresa el nombre de tu repositorio GitHub (ej: marcoantoniomejia/terra-nuevo): " GITHUB_REPO
read -p "Ingresa el entorno (dev/qa/prd): " ENVIRONMENT

# Variables
POOL_NAME="github-actions-pool"
PROVIDER_NAME="github-provider"
SA_NAME="github-actions-terraform-${ENVIRONMENT}"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo -e "\n${YELLOW}Configuración:${NC}"
echo "  Proyecto: $PROJECT_ID"
echo "  Repositorio: $GITHUB_REPO"
echo "  Entorno: $ENVIRONMENT"
echo "  Service Account: $SA_EMAIL"
echo ""

read -p "¿Continuar? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Configurar proyecto activo
echo -e "\n${GREEN}[1/7] Configurando proyecto activo...${NC}"
gcloud config set project $PROJECT_ID

# Habilitar APIs necesarias
echo -e "\n${GREEN}[2/7] Habilitando APIs necesarias...${NC}"
gcloud services enable iamcredentials.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable sts.googleapis.com

# Crear Service Account
echo -e "\n${GREEN}[3/7] Creando Service Account...${NC}"
if gcloud iam service-accounts describe $SA_EMAIL &>/dev/null; then
    echo "  ⚠️  Service Account ya existe, saltando..."
else
    gcloud iam service-accounts create $SA_NAME \
        --display-name="GitHub Actions Terraform - ${ENVIRONMENT}" \
        --description="Service Account para despliegues de Terraform desde GitHub Actions"
    echo "  ✅ Service Account creado"
fi

# Asignar roles al Service Account
echo -e "\n${GREEN}[4/7] Asignando roles al Service Account...${NC}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/editor" \
    --condition=None

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/storage.admin" \
    --condition=None

echo "  ✅ Roles asignados"

# Crear Workload Identity Pool
echo -e "\n${GREEN}[5/7] Creando Workload Identity Pool...${NC}"
if gcloud iam workload-identity-pools describe $POOL_NAME --location=global &>/dev/null; then
    echo "  ⚠️  Pool ya existe, saltando..."
else
    gcloud iam workload-identity-pools create $POOL_NAME \
        --location=global \
        --display-name="GitHub Actions Pool"
    echo "  ✅ Pool creado"
fi

# Crear Workload Identity Provider
echo -e "\n${GREEN}[6/7] Creando Workload Identity Provider...${NC}"
if gcloud iam workload-identity-pools providers describe $PROVIDER_NAME \
    --workload-identity-pool=$POOL_NAME \
    --location=global &>/dev/null; then
    echo "  ⚠️  Provider ya existe, saltando..."
else
    gcloud iam workload-identity-pools providers create-oidc $PROVIDER_NAME \
        --location=global \
        --workload-identity-pool=$POOL_NAME \
        --issuer-uri="https://token.actions.githubusercontent.com" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
        --attribute-condition="assertion.repository=='${GITHUB_REPO}'"
    echo "  ✅ Provider creado"
fi

# Permitir autenticación desde GitHub Actions
echo -e "\n${GREEN}[7/7] Configurando permisos de Workload Identity...${NC}"
gcloud iam service-accounts add-iam-policy-binding $SA_EMAIL \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/${POOL_NAME}/attribute.repository/${GITHUB_REPO}"

echo "  ✅ Permisos configurados"

# Obtener información para GitHub Secrets
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
WORKLOAD_IDENTITY_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_NAME}/providers/${PROVIDER_NAME}"

echo -e "\n${GREEN}=== ✅ Configuración completada ===${NC}\n"
echo -e "${YELLOW}Agrega los siguientes secretos en GitHub:${NC}"
echo -e "${YELLOW}(Settings > Secrets and variables > Actions > New repository secret)${NC}\n"

echo "Nombre: GCP_WORKLOAD_IDENTITY_PROVIDER"
echo "Valor: $WORKLOAD_IDENTITY_PROVIDER"
echo ""

echo "Nombre: GCP_SERVICE_ACCOUNT_EMAIL_$(echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]')"
echo "Valor: $SA_EMAIL"
echo ""

echo -e "${GREEN}También necesitarás configurar estos secretos para cada entorno.${NC}"
echo -e "${GREEN}Ejecuta este script para cada entorno (dev, qa, prd).${NC}\n"

# Guardar información en archivo
OUTPUT_FILE="gcp-auth-config-${ENVIRONMENT}.txt"
cat > $OUTPUT_FILE <<EOF
=== Configuración de Workload Identity Federation ===
Proyecto: $PROJECT_ID
Entorno: $ENVIRONMENT
Service Account: $SA_EMAIL

GitHub Secrets a configurar:
- GCP_WORKLOAD_IDENTITY_PROVIDER: $WORKLOAD_IDENTITY_PROVIDER
- GCP_SERVICE_ACCOUNT_EMAIL_$(echo $ENVIRONMENT | tr '[:lower:]' '[:upper:]'): $SA_EMAIL

Fecha: $(date)
EOF

echo -e "${GREEN}Información guardada en: $OUTPUT_FILE${NC}\n"
