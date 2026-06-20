variable "container_name" {
  type    = string
  default = "app-server"
}

variable "external_port" {
  type    = number
  default = 3000
}

variable "docker_host" {
  type    = string
  default = "npipe:////./pipe/docker_engine"
  description = "Docker host connection string. On Linux use unix:///var/run/docker.sock"
}

variable "prometheus_port" {
  type    = number
  default = 9090
}

variable "grafana_port" {
  type    = number
  default = 3000
}
