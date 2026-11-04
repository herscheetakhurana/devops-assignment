# Lab 4: Advanced Deployment Strategies & Enterprise DevOps

## Objective
Implement blue-green and canary deployments, GitOps-based delivery with ArgoCD, secret management with Vault, disaster recovery practices, and automated testing in CI/CD.

## Tools & Environment
| Tool | Purpose |
|------|---------|
| Jenkins | CI/CD automation |
| Kubernetes | Container orchestration |
| ArgoCD | GitOps continuous delivery |
| HashiCorp Vault | Secret management |
| Nginx Ingress | Traffic routing |

## Folder Structure
```
lab4-advanced-deployment-enterprise-devops/
+-- cicd-pipelines/
¦   +-- Jenkinsfile               # Enterprise pipeline
¦   +-- Jenkinsfile.blue-green    # Blue-green pipeline
¦   +-- Jenkinsfile.canary        # Canary pipeline
+-- deployment-strategies/
¦   +-- blue-green-deployment.yaml
¦   +-- canary-deployment.yaml
¦   +-- ingress.yaml
+-- gitops/
¦   +-- argocd-app.yaml
¦   +-- argocd-project.yaml
+-- scripts/
¦   +-- blue-green-switch.sh
¦   +-- canary-promote.sh
¦   +-- disaster-recovery.sh
¦   +-- secret-management.sh
+-- screenshots/
+-- reports/lab4-report.md
```

## Deployment Strategies
| Strategy | Downtime | Rollback | Use Case |
|----------|----------|----------|---------|
| Blue-Green | None | Instant | Zero-downtime releases |
| Canary | None | Fast | Risk-reduced rollouts |
| Rolling | Minimal | Medium | Standard updates |
| GitOps | None | Fast | Automated reconciliation |
