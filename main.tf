terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

resource "docker_network" "monitoring" {
  name = var.network_name
}

resource "docker_image" "appimage" {
  name = "pin-proyecto1-app:latest"
  build {
    context    = path.module
    dockerfile = "Dockerfile"
    target     = "production"
  }
}

resource "docker_container" "app_container" {
  image = docker_image.appimage.image_id
  name  = var.container_name

  ports {
    internal = 3000
    external = var.external_port
  }

  networks_advanced {
    name    = docker_network.monitoring.name
    aliases = ["app"]
  }

  restart = "unless-stopped"
}

resource "docker_volume" "prometheus_data" {}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:v2.54.1"
}

resource "docker_container" "prometheus" {
  image = docker_image.prometheus.image_id
  name  = "prometheus"

  ports {
    internal = 9090
    external = var.prometheus_port
  }

  volumes {
    host_path      = abspath("${path.module}/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
  ]

  networks_advanced {
    name = docker_network.monitoring.name
  }

  restart = "unless-stopped"
}

resource "docker_volume" "grafana_data" {}

resource "docker_image" "grafana" {
  name = "grafana/grafana:10.4.5"
}

resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "grafana"

  ports {
    internal = 3000
    external = var.grafana_port
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=admin",
    "GF_USERS_ALLOW_SIGN_UP=false",
  ]

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  volumes {
    host_path      = abspath("${path.module}/grafana/provisioning")
    container_path = "/etc/grafana/provisioning"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/grafana/dashboards")
    container_path = "/etc/grafana/dashboards"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.monitoring.name
  }

  restart = "unless-stopped"
}

resource "docker_image" "node_exporter" {
  name = "quay.io/prometheus/node-exporter:latest"
}

resource "docker_container" "node_exporter" {
  image   = docker_image.node_exporter.image_id
  name    = "node_exporter"
  command = ["--path.rootfs=/host"]
  pid_mode = "host"

  volumes {
    host_path      = "/"
    container_path = "/host"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.monitoring.name
  }

  restart = "unless-stopped"
}

resource "docker_image" "cadvisor" {
  name = "gcr.io/cadvisor/cadvisor:latest"
}

resource "docker_container" "cadvisor" {
  image = docker_image.cadvisor.image_id
  name  = "cadvisor"

  ports {
    internal = 8080
    external = var.cadvisor_port
  }

  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = true
  }

  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }

  volumes {
    host_path      = "/var/lib/docker"
    container_path = "/var/lib/docker"
    read_only      = true
  }

  volumes {
    host_path      = "/dev/disk"
    container_path = "/dev/disk"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.monitoring.name
  }

  restart = "unless-stopped"
}
