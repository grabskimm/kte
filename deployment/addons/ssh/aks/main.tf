provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

data "azurerm_kubernetes_cluster" "aks" {
  name = var.cluster_name
  resource_group_name = var.resource_group_name
}

provider "kubernetes" {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "ssh" {
  metadata {
    name = "ssh"
  }
}

resource "kubernetes_pod" "ssh-server" {
  metadata {
    name = "ssh-server"
    labels = {
      app = "ssh-server"
    }
    namespace = "ssh"
  }

  spec {
    container {
      name = "ssh-server"
      image = "ghcr.io/roin-orca/openssh-server"

      port {
        container_port = 2222
      }

      env {
        name = "PUBLIC_KEY"
        value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAxlJJwv5rrk1/j1twJ/0kkCfPAi/7RYnOAD9vbDqSWKa5BgcFd9HvY20GhDin5YwnWTJsgAx7cx5R83VBQjs5zmKKvLQYng2qGQtsgxey4sAW2/8Zo3pmelTRpYXQx4JHGtjlgzVbVlOYNXWJNuyvB2SNE/HlhEJnEYnsLVLuvu+GJEJsvUpb0q0Ul4rBEelxguemSSmUtg/wCQxumHunwxXabWVe3isgzNZNVeN15xAKXi8olAej750MO9RhlFUWZiwpmFhNjlkbfiMHZm/LD8M6MU5FhZQga1BUWz0snMzaseDEoGcwwXwLS3dEQu+sHjJ05scFUhwAtvaz+x+sPzp0DwwtKEdOMnsFBZKUEki0krm75jU9+qTJTh3ysVAC074ftYvg5sbND1w+bpUbjm/0M5IBh1K2aYOlBKeI4bRp7VrPboLYAcgQOJ7xGRvTgvMK+NzFIeKmXVa3VKeKVD8pTujLxtp01DXHJqRfcDrv9MT9Qz5B5bpSioMD3YNaeTc3trCCf/DM5Ua4u8jHf7/mMiB9qeEPpC7K6foAu/s5+YlllVdTEZpdpZO7KU8MGueWJ3mw2hr/352vV55jnSVH//I4B8vnByy7VMXOVZxzd7Ms4wu6fGv/EqxZjdVA/6flot7BjkjESOAkv8maGy2t2Odl22FgUXRmGBYXJw== roinisimi@IL-RNS-M-ROINIS"
      }

      env {
        name = "SUDO_ACCESS"
        value = true
      }
    }
  }
}

resource "kubernetes_service" "ssh-server" {
  metadata {
    name = "ssh-server"
    namespace = "ssh"
  }

  spec {
    selector = {
      app = "ssh-server"
    }

    port {
      port = 2222
      target_port = 2222
    }

    type = "LoadBalancer"
  }
}