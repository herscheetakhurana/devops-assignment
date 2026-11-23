# ============================================================
# Capstone: Terraform Infrastructure Configuration
# ============================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "local" {}

# Generate application environment config
resource "local_file" "app_config" {
  filename = "${path.module}/../../app/.env"
  content  = <<-EOT
    NODE_ENV=${var.environment}
    PORT=${var.app_port}
    APP_VERSION=${var.app_version}
    LOG_LEVEL=${var.log_level}
  EOT
}

# Generate Prometheus scrape targets
resource "local_file" "prometheus_targets" {
  filename = "${path.module}/../../monitoring/generated-targets.json"
  content = jsonencode({
    targets = [for ip in var.web_server_ips : "${ip}:9100"]
    labels  = { env = var.environment, project = "capstone" }
  })
}

# Create Docker network
resource "null_resource" "docker_network" {
  provisioner "local-exec" {
    command = "docker network create ${var.docker_network_name} 2>/dev/null || true"
  }
  triggers = {
    network_name = var.docker_network_name
  }
}

# Post-provisioning verification
resource "null_resource" "verify" {
  depends_on = [local_file.app_config]
  provisioner "local-exec" {
    command = "echo 'Capstone infrastructure provisioned for: ${var.environment}'"
  }
}
