output "subnets" {
  description = "Las subredes existentes."
  value       = data.google_compute_subnetwork.subnets
}

output "network_self_link" {
  description = "El self-link de la red."
  value       = values(data.google_compute_subnetwork.subnets)[0].network
}
