terraform {
  backend "gcs" {
    bucket  = "your-gcs-bucket-name-qa"
    prefix  = "qa"
  }
}
