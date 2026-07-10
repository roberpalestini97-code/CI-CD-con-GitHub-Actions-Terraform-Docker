output "container_name" {
  value = docker_container.app_container.name
}

output "container_id" {
  value = docker_container.app_container.id
}

output "app_url" {
  value = "http://localhost:${var.external_port}"
}

output "prometheus_url" {
  value = "http://localhost:${var.prometheus_port}"
}

output "grafana_url" {
  value = "http://localhost:${var.grafana_port}"
}

output "prometheus_container_id" {
  value = docker_container.prometheus.id
}

output "grafana_container_id" {
  value = docker_container.grafana.id
}

output "network_name" {
  value = docker_network.monitoring.name
}
