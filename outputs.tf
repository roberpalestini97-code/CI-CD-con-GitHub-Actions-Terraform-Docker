output "container_name" {
  value = docker_container.app_container.name
}

output "container_id" {
  value = docker_container.app_container.id
}
