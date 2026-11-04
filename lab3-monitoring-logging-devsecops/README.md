# Lab 3: Monitoring, Logging & DevSecOps

## Objective
Design an automated, observable, and secure infrastructure. Automate provisioning with Ansible and Terraform, implement monitoring with Prometheus/Grafana, centralized logging with the ELK stack, and integrate security scanning and browser testing.

## Tools & Environment
| Tool | Purpose |
|------|---------|
| Ansible | Configuration management & provisioning |
| Terraform | Infrastructure as Code |
| Prometheus | Metrics collection |
| Grafana | Metrics visualization |
| Elasticsearch | Log storage & search |
| Logstash | Log ingestion & transformation |
| Kibana | Log visualization |
| Trivy | Container security scanning |
| Selenium | Automated browser testing |

## Folder Structure
```
lab3-monitoring-logging-devsecops/
+-- ansible/
¦   +-- inventory.ini         # Host inventory
¦   +-- playbook.yml          # Main Ansible playbook
+-- terraform/
¦   +-- main.tf               # Main Terraform config
¦   +-- variables.tf          # Input variables
¦   +-- outputs.tf            # Output values
+-- monitoring-configs/
¦   +-- docker-compose-monitoring.yml  # Full monitoring stack
¦   +-- prometheus.yml        # Prometheus scrape config
¦   +-- alertmanager.yml      # Alerting rules
¦   +-- logstash.conf         # Logstash pipeline config
+-- scripts/
¦   +-- elk-setup.sh          # ELK stack bootstrap
¦   +-- security-scan.sh      # Trivy security scan
+-- screenshots/
+-- reports/
    +-- lab3-report.md
```

## Experiments Covered
1. Write Ansible playbook to provision and configure servers
2. Use Terraform to define and apply infrastructure
3. Deploy Prometheus + Grafana monitoring stack
4. Set up ELK stack for centralized logging
5. Configure alerting rules in Alertmanager
6. Run Trivy container security scan
7. Implement Selenium browser tests
