variable "project_id" {
  description = "El ID del proyecto donde se crearán las instancias."
  type        = string
}

variable "subnets" {
  description = "Un mapa de las subredes."
  type        = any
}

variable "instances" {
  description = "Un mapa de instancias para crear."
  type = map(object({
    name         = string
    machine_type = string
    zone         = string
    subnet_name  = string
    tags         = list(string)
    external_ip  = bool
  }))
}
