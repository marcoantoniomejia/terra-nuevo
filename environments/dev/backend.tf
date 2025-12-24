terraform {
  backend "gcs" {
    bucket  = "bucket-terraform-state-siesaprueba"
    prefix  = "dev"
  }
}
