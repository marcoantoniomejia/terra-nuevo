variable "bucket_name" {
  description = "El nombre del bucket de GCS para almacenar el estado de Terraform"
  type        = string
}

variable "project_id" {
  description = "El ID del proyecto de GCP donde se creará el bucket"
  type        = string
}

variable "location" {
  description = "La ubicación del bucket de GCS"
  type        = string
  default     = "US"
}

variable "environment" {
  description = "El entorno para el cual se crea el bucket (dev, qa, prd)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "prd"], var.environment)
    error_message = "El entorno debe ser dev, qa o prd"
  }
}
