provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_container_cluster" "gke" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.gke.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

resource "helm_release" "checkov" {
  name             = "checkov"
  chart            = "../charts/checkov"
  namespace        = "checkov"
  create_namespace = true
}