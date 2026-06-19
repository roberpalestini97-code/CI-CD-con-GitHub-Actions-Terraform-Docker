terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "appimage" {
  name = "pin-proyecto1-app:latest"
}

resource "docker_container" "app_container" {
  image = docker_image.appimage.image_id
  name  = var.container_name

  ports {
    internal = 3000
    external = var.external_port
  }
}

