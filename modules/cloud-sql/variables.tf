variable "project_id" {
  description = "El ID del proyecto donde se creará la instancia de Cloud SQL."
  type        = string
}

variable "instance_name" {
  description = "El nombre de la instancia de Cloud SQL."
  type        = string
}

variable "database_version" {
  description = "La versión de la base de datos a utilizar."
  type        = string
}

variable "tier" {
  description = "El tipo de máquina a utilizar para la instancia."
  type        = string
}

variable "zone" {
  description = "La zona para la instancia."
  type        = string
}

variable "network_self_link" {
  description = "El self-link de la red."
  type        = string
}

variable "psa_peering_range_name" {
  description = "El nombre del rango de peering para la conexión de servicios privados. Si se deja en blanco, se creará uno nuevo."
  type        = string
  default     = ""
}

variable "host_project_id" {
  description = "El ID del proyecto anfitrión donde se encuentra la VPC compartida."
  type        = string
}