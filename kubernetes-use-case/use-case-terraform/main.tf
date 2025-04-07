provider "google" {
  credentials = file("C:/Users/egeye/Downloads/gke-case-study-884aa3852690.json")
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name     = "gke-case-cluster"
  location = var.region

  remove_default_node_pool = true
  initial_node_count       = 1

  logging_service    = "none"
  monitoring_service = "none"

  network    = "default"
  subnetwork = "default"
}

resource "google_container_node_pool" "main_pool" {
  name       = "main-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "n2d-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }
}

resource "google_container_node_pool" "application_pool" {
  name     = "application-pool"
  location = var.region
  cluster  = google_container_cluster.primary.name

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    machine_type = "n2d-standard-2"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      pool = "application"
    }

    taint {
      key    = "pool"
      value  = "application"
      effect = "NO_SCHEDULE"
    }
  }

  # Auto-scaling yapılandırması eklenmeli
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }
}
