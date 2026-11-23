# Capstone Project: End-to-End DevOps Automation Platform

**Student:** Herscheeta Khurana  
**Date:** November 2026  
**Repository:** https://github.com/herscheetakhurana/devops-assignment  
**Marks:** 120

---

## Project Overview

This capstone project delivers a **complete, production-ready DevOps automation platform** for a Node.js web application. The platform integrates every layer of the modern DevOps stack — from code commit to production deployment — with observability, security, and recoverability built in.

### Application: DevOps Sample App
A Node.js + Express REST API with health checks, metrics endpoint, and versioned releases, used as the deployment target throughout the platform.

---

## Architecture

```
Developer Push
      |
      v
  GitHub (Source of Truth)
      |
      +---> GitHub Actions CI
      |         |-- npm install & lint
      |         |-- Jest unit tests (coverage)
      |         |-- Docker build
      |         |-- Trivy security scan
      |         |-- Push to Docker Hub
      |         |-- ArgoCD sync trigger
      |
      v
  ArgoCD (GitOps Controller)
      |
      v
  Kubernetes (Minikube / production)
      |
      +-- Blue-Green Deployment
      +-- Canary Deployment
      +-- Rolling Update
      |
      v
  Observability Stack
      |
      +-- Prometheus (metrics)
      +-- Grafana (dashboards)
      +-- ELK Stack (logs)
      +-- AlertManager (alerts)
      |
      v
  Security Layer
      |
      +-- Trivy (image scanning)
      +-- HashiCorp Vault (secrets)
      +-- RBAC policies
```

---

## Repository Structure

```
capstone/
├── app/                    # Node.js application source
│   ├── src/
│   │   ├── index.js        # Main application entry point
│   │   └── routes/         # API route handlers
│   ├── tests/
│   │   └── app.test.js     # Jest unit tests
│   └── package.json
├── pipeline/               # CI/CD pipeline definitions
│   ├── Jenkinsfile         # Jenkins declarative pipeline
│   └── github-actions.yml  # GitHub Actions workflow
├── docker/                 # Containerization
│   ├── Dockerfile          # Multi-stage production Dockerfile
│   └── docker-compose.yml  # Local development stack
├── k8s/                    # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── blue-green.yaml
│   └── canary.yaml
├── infrastructure/         # Infrastructure as Code
│   ├── ansible/
│   │   ├── inventory.ini
│   │   └── playbook.yml
│   └── terraform/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── monitoring/             # Observability stack
│   ├── prometheus.yml
│   ├── alertmanager.yml
│   ├── logstash.conf
│   └── docker-compose-monitoring.yml
├── security/               # Security scanning
│   └── trivy-policy.yaml
├── gitops/                 # ArgoCD GitOps
│   ├── argocd-app.yaml
│   └── argocd-project.yaml
├── scripts/                # Automation scripts
│   ├── deploy.sh
│   ├── blue-green-switch.sh
│   ├── canary-promote.sh
│   ├── disaster-recovery.sh
│   └── secret-management.sh
├── logs/                   # Sample execution logs
│   ├── ci-pipeline.log
│   ├── deployment.log
│   └── trivy-scan.log
└── docs/
    └── capstone-report.md  # Full capstone report
```

---

## Quick Start

### Prerequisites
- Docker 26.x
- Kubernetes (Minikube v1.34)
- kubectl
- Ansible 9.x
- Terraform 1.9.x

### 1. Clone and Setup
```bash
git clone https://github.com/herscheetakhurana/devops-assignment.git
cd devops-assignment/capstone
```

### 2. Run Application Locally
```bash
cd app
npm install
npm start
# App available at http://localhost:3000
curl http://localhost:3000/health
```

### 3. Build Docker Image
```bash
docker build -t devops-capstone-app:1.0.0 -f docker/Dockerfile app/
docker run -p 3000:3000 devops-capstone-app:1.0.0
```

### 4. Deploy to Kubernetes
```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods -n capstone
```

### 5. Start Monitoring Stack
```bash
cd monitoring
docker compose -f docker-compose-monitoring.yml up -d
# Grafana: http://localhost:3001 (admin/devops123)
# Prometheus: http://localhost:9090
```

### 6. Run Security Scan
```bash
bash scripts/deploy.sh scan devops-capstone-app:1.0.0
```

---

## Key Results

| Component | Status | Evidence |
|-----------|--------|---------|
| CI/CD Pipeline | Running | GitHub Actions passing |
| Docker Image | Built | devops-capstone-app:1.0.0 |
| Kubernetes | Deployed | 3/3 pods running |
| Monitoring | Active | Prometheus + Grafana dashboards |
| Security Scan | 0 CRITICAL | Trivy scan report |
| GitOps | Synced | ArgoCD Healthy |
| Disaster Recovery | RTO: 87s | DR drill completed |

---

## Student Information
- **Name:** Herscheeta Khurana  
- **Environment:** Ubuntu 24.04 LTS, Kubernetes Minikube v1.34, Docker 26.x  
- **GitHub:** https://github.com/herscheetakhurana/devops-assignment  
