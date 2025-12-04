terraform {
  backend "gcs" {
    bucket  = "your-gcs-bucket-name-prd"
    prefix  = "prd"
  }
}
