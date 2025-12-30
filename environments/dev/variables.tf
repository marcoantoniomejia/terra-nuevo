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

variable "create_service_project_attachment" {
  description = "A boolean flag to control the creation of the service project attachment."
  type        = bool
  default     = true
}

variable "create_service_networking_connection" {
  description = "A boolean flag to control the creation of the service networking connection."
  type        = bool
  default     = true
}

variable "subnet_names" {
  description = "A list of subnet names to be used."
  type        = list(string)
}

variable "network_name" {
  description = "The name of the network."
  type        = string
}

variable "compute_instances" {
  description = "A map of compute instances to be created."
  type        = any # Using 'any' for simplicity with complex nested objects
}

variable "cloud_sql_instance_name" {
  description = "The name of the Cloud SQL instance."
  type        = string
}

variable "cloud_sql_database_version" {
  description = "The database version for the Cloud SQL instance."
  type        = string
}

variable "cloud_sql_tier" {
  description = "The machine type for the Cloud SQL instance."
  type        = string
}

variable "cloud_sql_zone" {
  description = "The zone for the Cloud SQL instance."
  type        = string
}

variable "cloud_sql_psa_peering_range_name" {
  description = "The name of the PSA peering range for the Cloud SQL connection."
  type        = string
}
