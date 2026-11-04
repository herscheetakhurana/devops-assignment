variable "environment" {
  description = "Deployment environment (development, staging, production)"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "app_version" {
  description = "Application version to deploy"
  type        = string
  default     = "1.0.0"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 3000
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
}

variable "web_server_ips" {
  description = "List of web server IP addresses for monitoring"
  type        = list(string)
  default     = ["192.168.1.10", "192.168.1.11"]
}

variable "docker_network_name" {
  description = "Docker network name for lab services"
  type        = string
  default     = "lab3-network"
}
