output "environment" {
  value = var.environment
}

output "app_config_path" {
  value = local_file.app_config.filename
}

output "monitoring_targets" {
  value = [for ip in var.web_server_ips : "${ip}:9100"]
}

output "docker_network" {
  value = var.docker_network_name
}
