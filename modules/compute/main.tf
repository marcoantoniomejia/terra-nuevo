resource "google_compute_instance" "instances" {
  for_each      = var.instances
  project       = var.project_id
  zone          = each.value.zone
  name          = each.value.name
  machine_type  = each.value.machine_type
  tags          = each.value.tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.subnets[each.value.subnet_name].self_link
    dynamic "access_config" {
      for_each = each.value.external_ip ? [1] : []
      content {}
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
