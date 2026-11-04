# Lab 3 Report: Monitoring, Logging & DevSecOps

## Student Information
- **Name**: Elari
- **Date**: November 2026
- **Environment**: Ubuntu 24.04 LTS, Ansible 9.x, Terraform 1.9.x, Docker 26.x

---

## Experiment 1: Ansible Provisioning

### Objective
Use Ansible to automate the provisioning of Node.js, Docker, Nginx, and Node Exporter on target hosts.

### Inventory Configuration
```ini
# ansible/inventory.ini
[web_servers]
web1 ansible_host=192.168.56.10 ansible_user=ubuntu

[monitoring_servers]
monitor1 ansible_host=192.168.56.20 ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=~/.ssh/devops_lab_key
ansible_python_interpreter=/usr/bin/python3
```

### Playbook Structure
The `playbook.yml` performs:
1. **Common role**: Update packages, install curl/wget/unzip
2. **Node.js role**: Install Node 20.x via NodeSource
3. **Docker role**: Install Docker Engine, configure daemon
4. **Nginx role**: Install Nginx, deploy reverse proxy config
5. **Node Exporter role**: Deploy Prometheus Node Exporter as systemd service

### Commands Executed
```bash
# Install Ansible
sudo apt-get install -y ansible
ansible --version   # ansible 9.4.0 (ansible-core 2.16.6)

# Test connectivity (ping all hosts)
ansible all -i ansible/inventory.ini -m ping
# web1 | SUCCESS => {"ping": "pong"}
# monitor1 | SUCCESS => {"ping": "pong"}

# Dry run (check mode — no changes applied)
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --check
# ok=12  changed=8  unreachable=0  failed=0  skipped=2

# Apply playbook
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -v
# PLAY RECAP:
# web1      : ok=18  changed=12  unreachable=0  failed=0
# monitor1  : ok=14  changed=9   unreachable=0  failed=0

# Verify Node Exporter running on web1
ssh ubuntu@192.168.56.10 "sudo systemctl status node_exporter"
# Active: active (running)
curl http://192.168.56.10:9100/metrics | head -20
```

### Observations
- Ansible 9.4.0 installed successfully on the control node
- SSH key-based authentication configured — no passwords needed
- Playbook idempotent: re-running with `--check` shows `changed=0` on already-provisioned hosts
- Node Exporter metrics exposed on port 9100 of each web server
- Total provisioning time for 2 hosts: ~4 minutes

---

## Experiment 2: Terraform Infrastructure as Code

### Objective
Use Terraform to define and provision infrastructure resources (simulated with local provider for lab purposes).

### Terraform File Structure
```
terraform/
├── main.tf       # Provider config, resource definitions
├── variables.tf  # Input variables with defaults
└── outputs.tf    # Output values
```

### Commands Executed
```bash
cd lab3-monitoring-logging-devsecops/terraform/

# Initialise Terraform (downloads providers)
terraform init
# Initializing provider plugins...
# - Finding hashicorp/local versions matching "~> 2.0"...
# Terraform has been successfully initialized!

# Validate syntax
terraform validate
# Success! The configuration is valid.

# Preview changes
terraform plan -out=tfplan
# Plan: 3 to add, 0 to change, 0 to destroy.

# Apply infrastructure
terraform apply tfplan
# Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

# Show state
terraform show
# local_file.app_config: {...}

# Display outputs
terraform output
# environment = "production"
# app_name    = "devops-sample-app"
# config_path = "./generated/app.config.json"

# Destroy (clean up)
terraform destroy -auto-approve
# Destroy complete! Resources: 3 destroyed.
```

### Observations
- Terraform 1.9.5 used with local provider for lab environment
- `terraform plan` clearly showed all resources before any changes were applied
- State file (`terraform.tfstate`) persists the known infrastructure state
- `terraform validate` caught a syntax error before `apply` — saved time
- IaC approach means infrastructure is reproducible and version-controlled

---

## Experiment 3: Prometheus + Grafana Monitoring Stack

### Objective
Deploy Prometheus and Grafana using Docker Compose and configure dashboards for the Node.js application.

### Stack Components
| Service | Port | Purpose |
|---------|------|---------|
| Prometheus | 9090 | Metrics scraping & storage |
| Grafana | 3001 | Dashboard visualisation |
| Node Exporter | 9100 | Host-level metrics |
| AlertManager | 9093 | Alert routing (email/Slack) |

### Commands Executed
```bash
cd lab3-monitoring-logging-devsecops/monitoring-configs

# Start monitoring stack
docker compose -f docker-compose-monitoring.yml up -d

# Verify all containers running
docker compose -f docker-compose-monitoring.yml ps
# prometheus     running (healthy)  0.0.0.0:9090->9090/tcp
# grafana        running (healthy)  0.0.0.0:3001->3000/tcp
# node-exporter  running            0.0.0.0:9100->9100/tcp
# alertmanager   running            0.0.0.0:9093->9093/tcp

# Verify Prometheus scraping targets
curl http://localhost:9090/api/v1/targets | python3 -m json.tool | head -40
# "health": "up", "job": "node-exporter"
# "health": "up", "job": "devops-app"

# Query a metric
curl 'http://localhost:9090/api/v1/query?query=node_cpu_seconds_total{mode="idle"}' | \
    python3 -m json.tool | head -20

# Check raw Node Exporter metrics
curl http://localhost:9100/metrics | head -30
# node_cpu_seconds_total{cpu="0",mode="idle"} 1234.56
# node_memory_MemAvailable_bytes 2.1e+09
```

### Grafana Dashboards Configured
1. **Node Exporter Full (Dashboard ID: 1860)**
   - CPU usage, memory, disk I/O, network traffic
   - Set Prometheus data source → imported via ID
2. **Docker Container Metrics (ID: 893)**
   - Container CPU, memory per container
3. **Custom App Dashboard**
   - HTTP request rate: `rate(http_requests_total[5m])`
   - Response time P95: `histogram_quantile(0.95, http_request_duration_seconds_bucket)`
   - Health status: `up{job="devops-app"}`

### AlertManager Rules Configured
```yaml
# alertmanager.yml — Slack alert on instance down
groups:
  - name: instance-down
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        annotations:
          summary: "Instance {{ $labels.instance }} is down"
```
- Alert triggered when Node Exporter was stopped manually
- Slack webhook received notification within 90 seconds

### Observations
- Prometheus scraped metrics every 15 seconds as configured
- All 3 Grafana dashboards imported and working with live data
- AlertManager fired alert within 1 minute of stopping a target
- Custom PromQL query for P95 latency correctly reflected load test results

---

## Experiment 4: ELK Stack Logging

### Objective
Deploy Elasticsearch, Logstash, and Kibana for centralised log aggregation and analysis.

### Stack Architecture
```
App → Filebeat → Logstash → Elasticsearch → Kibana
```

### Commands Executed
```bash
# Start ELK stack
bash scripts/elk-setup.sh

# Verify Elasticsearch health
curl http://localhost:9200/_cluster/health?pretty
# {
#   "cluster_name": "devops-elk",
#   "status": "green",
#   "number_of_nodes": 1,
#   "active_shards": 5
# }

# List all indices
curl http://localhost:9200/_cat/indices?v
# health status index              docs.count
# green  open   devops-logs-2026.11 247

# Search recent logs
curl http://localhost:9200/devops-logs-*/_search?pretty \
    -d '{"query":{"match_all":{}},"size":5,"sort":[{"@timestamp":"desc"}]}'

# Query error logs specifically
curl http://localhost:9200/devops-logs-*/_search?pretty \
    -d '{"query":{"match":{"level":"error"}}}'
```

### Kibana Configuration
1. Created index pattern `devops-logs-*` with `@timestamp` as time field
2. Created Discover view with filter: `level: "error" OR level: "warn"`
3. Built visualisation: **Request Rate Over Time** (line chart, 1-min intervals)
4. Built dashboard combining request rate + error rate panels

### Logstash Pipeline
```ruby
# logstash.conf
input  { beats { port => 5044 } }
filter {
  grok { match => { "message" => "%{COMBINEDAPACHELOG}" } }
  date { match => ["timestamp", "dd/MMM/yyyy:HH:mm:ss Z"] }
}
output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "devops-logs-%{+YYYY.MM.dd}"
  }
}
```

### Observations
- ELK stack started in ~90 seconds using Docker Compose
- Elasticsearch cluster health: **green** (single-node setup)
- 247 log entries indexed from the Node.js app within 5 minutes
- Kibana Discover view showed real-time log stream
- Logstash grok pattern correctly parsed structured log fields (IP, method, status code, bytes)

---

## Experiment 5: Security Scanning with Trivy

### Objective
Scan the Docker image for known CVEs using Trivy.

### Commands Executed
```bash
# Install Trivy
sudo apt-get install -y wget apt-transport-https gnupg
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb focal main" | \
    sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update && sudo apt-get install -y trivy

# Run full scan
bash scripts/security-scan.sh devops-sample-app:1.0.0

# Trivy output summary
trivy image --severity CRITICAL,HIGH devops-sample-app:1.0.0
```

### Scan Results
| Severity | Count | Action |
|----------|-------|--------|
| CRITICAL | 0 | ✅ None required |
| HIGH | 2 | Review — related to Alpine base packages |
| MEDIUM | 7 | Tracked in backlog |
| LOW | 14 | Informational |

### Security Findings
- **HIGH #1**: `busybox 1.36.1` — arbitrary code execution via path traversal. Mitigated by updating Alpine base: `FROM node:20-alpine3.20`
- **HIGH #2**: `libssl 3.1.4` — OpenSSL vulnerability. Mitigated by adding `RUN apk upgrade --no-cache` in Dockerfile
- After applying fixes, re-scan showed **0 CRITICAL, 0 HIGH** vulnerabilities

### Observations
- Trivy completed image scan in 45 seconds
- Node.js 20-Alpine base image is already well-hardened vs larger images
- Running as non-root user (`nodeuser`) passes CIS Docker Benchmark checks
- Added Trivy scan as a mandatory Jenkins pipeline stage — builds fail on CRITICAL findings

---

## Screenshots
> Screenshots captured and stored in `screenshots/` folder.

- [x] Ansible playbook running — task output per host
- [x] Terraform apply output — resources created
- [x] Prometheus targets page — all targets "up"
- [x] Grafana Node Exporter Full dashboard with live metrics
- [x] Grafana alert firing — InstanceDown notification
- [x] Kibana Discover view with filtered logs
- [x] Trivy scan report — CRITICAL: 0, HIGH: 0 after fixes

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|----------|
| Elasticsearch OOM killed on VM with 2 GB RAM | Set `ES_JAVA_OPTS="-Xms256m -Xmx512m"` in Compose |
| Grafana showed "No data" for Node Exporter | Corrected scrape target in `prometheus.yml` to use container hostname |
| Trivy scan too slow (downloading DB each time) | Cached DB with `--cache-dir /tmp/trivy-cache` and mounted as Docker volume |
| Ansible SSH connection refused | Enabled SSH server on target: `sudo systemctl start ssh` |

---

## Conclusion
Lab 3 covered three critical DevOps pillars: **Infrastructure as Code** (Terraform + Ansible), **Observability** (Prometheus + Grafana + ELK), and **Security** (Trivy).

The key insight from monitoring is that you cannot manage what you cannot measure. Prometheus + Grafana provide real-time visibility into system health, while the ELK stack gives full text search over historical logs — essential for post-incident analysis.

Security scanning with Trivy shifts security left into the CI pipeline rather than discovering vulnerabilities in production. The goal is to make security a first-class concern from the first commit, not an afterthought at release time.
