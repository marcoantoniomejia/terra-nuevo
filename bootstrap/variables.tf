variable "bucket_name" {
  description = "El nombre del bucket de GCS que se creará para el estado de Terraform."
  type        = string
}

variable "project_id" {
  description = "El ID del proyecto de GCP."
  type        = string
}

variable "location" {
  description = "La ubicación para el bucket de GCS."
  type        = string
  default     = "US"
}
