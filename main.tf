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

resource "docker_image" "appimage" {
  name = "pin-proyecto1-app:latest"
  build {
    context    = "${path.module}"
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
}

# Prometheus
resource "docker_volume" "prometheus_data" {}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  image = docker_image.prometheus.image_id
  name  = "prometheus"

  ports {
    internal = 9090
    external = var.prometheus_port
  }

  volumes = [
    "${path.module}/prometheus.yml:/etc/prometheus/prometheus.yml:ro",
    "${docker_volume.prometheus_data.name}:/prometheus",
  ]

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
  ]
}

# Grafana
resource "docker_volume" "grafana_data" {}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  image = docker_image.grafana.image_id
  name  = "grafana"

  ports {
    internal = 3000
    external = var.grafana_port
  }

  volumes = [
    "${docker_volume.grafana_data.name}:/var/lib/grafana",
  ]
}

