output "environment" {
  description = "Current deployment environment"
  value       = var.environment
}

output "app_config_path" {
  description = "Path to generated app config"
  value       = local_file.app_config.filename
}

output "monitoring_targets" {
  description = "Prometheus scrape targets"
  value       = [for ip in var.web_server_ips : "${ip}:9100"]
}

output "docker_network" {
  description = "Docker network name"
  value       = var.docker_network_name
}
