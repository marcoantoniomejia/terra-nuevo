terraform {
  backend "gcs" {
    bucket  = "your-gcs-bucket-name-dev"
    prefix  = "dev"
  }
}
