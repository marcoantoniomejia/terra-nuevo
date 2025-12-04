output "bucket_name" {
  description = "El nombre del bucket de GCS creado."
  value       = google_storage_bucket.backend.name
}
