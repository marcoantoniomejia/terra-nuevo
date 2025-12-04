variable "host_project_id" {
  description = "El ID del proyecto anfitrión donde se encuentra la VPC compartida."
  type        = string
}

variable "service_project_id" {
  description = "El ID del proyecto de servicio donde se crearán los recursos."
  type        = string
}

variable "region" {
  description = "La región donde se crearán los recursos."
  type        = string
}
