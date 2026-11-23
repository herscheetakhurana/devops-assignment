variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Must be development, staging, or production."
  }
}

variable "app_version" {
  type    = string
  default = "1.0.0"
}

variable "app_port" {
  type    = number
  default = 3000
}

variable "log_level" {
  type    = string
  default = "info"
}

variable "web_server_ips" {
  type    = list(string)
  default = ["192.168.1.10", "192.168.1.11"]
}

variable "docker_network_name" {
  type    = string
  default = "capstone-network"
}
