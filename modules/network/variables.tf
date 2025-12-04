variable "host_project_id" {
  description = "El ID del proyecto anfitrión."
  type        = string
}

variable "service_project_id" {
  description = "El ID del proyecto de servicio."
  type        = string
}

variable "subnets" {
  description = "Un mapa de subredes para crear."
  type = map(object({
    name          = string
    cidr          = string
    region        = string
    private_ip_google_access = optional(bool, true)
  }))
}
