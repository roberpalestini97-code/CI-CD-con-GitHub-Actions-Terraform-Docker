output "container_name" {
  value = docker_container.app_container.name
}

output "container_id" {
  value = docker_container.app_container.id
}

output "prometheus_container_id" {
  value = docker_container.prometheus.id
}

output "grafana_container_id" {
  value = docker_container.grafana.id
}
