# DevOps Assignment Repository

A complete DevOps workflow covering CI/CD, containerization, monitoring, and advanced deployment strategies.

## Repository Structure

```
devops.assignment/
+-- app/                               # Sample Node.js application (used across all labs)
+-- lab1-devops-foundations-ci/        # Lab 1: DevOps Foundations & CI
+-- lab2-containerization-kubernetes/  # Lab 2: Containerization & Kubernetes
+-- lab3-monitoring-logging-devsecops/ # Lab 3: Monitoring, Logging & DevSecOps
+-- lab4-advanced-deployment-enterprise-devops/ # Lab 4: Advanced Deployment
```

## Labs Overview

| Lab | Topic | Key Tools |
|-----|-------|-----------|
| Lab 1 | DevOps Foundations & CI | Git, Jenkins, Ubuntu 24.04 |
| Lab 2 | Containerization & Kubernetes | Docker, Docker Compose, Minikube, kubectl |
| Lab 3 | Monitoring, Logging & DevSecOps | Ansible, Terraform, Prometheus, Grafana, ELK |
| Lab 4 | Advanced Deployment & Enterprise DevOps | Jenkins, ArgoCD, Kubernetes, Vault |

## Sample Application

The `app/` directory contains a simple Node.js + Express web application used as the target for all lab experiments.

- **Port**: 3000
- **Endpoints**: `/` (home), `/health` (health check), `/api/info` (app info)

## Commit Convention

```
feat:   new feature or experiment
fix:    bug fix
docs:   documentation only
config: configuration changes
ci:     CI/CD pipeline changes
chore:  maintenance tasks
```
