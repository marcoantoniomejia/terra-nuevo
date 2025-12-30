variable "host_project_id" {
  description = "El ID del proyecto anfitrión."
  type        = string
}

variable "service_project_id" {
  description = "El ID del proyecto de servicio."
  type        = string
}

variable "subnet_names" {
  description = "Una lista de nombres de subredes existentes."
  type        = list(string)
}

variable "region" {
  description = "La región donde se encuentran las subredes."
  type        = string
}

variable "network_name" {
  description = "El nombre de la red."
  type        = string
}

variable "create_service_project_attachment" {
  description = "A boolean flag to control the creation of the service project attachment. Set to false if the attachment already exists."
  type        = bool
  default     = true
}