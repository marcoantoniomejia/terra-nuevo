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

variable "subnet_name" {
  description = "El nombre de la subred a la que se adjuntará la instancia."
  type        = string
}

variable "subnets" {
  description = "Un mapa de las subredes."
  type        = any
}

variable "network_self_link" {
  description = "El self-link de la red."
  type        = string
}
