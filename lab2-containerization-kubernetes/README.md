# Lab 2: Containerization & Kubernetes Orchestration

## Objective
Containerize the sample Node.js application with Docker, manage images and containers with Docker Compose, and deploy/scale/update it on a Kubernetes (Minikube) cluster.

## Tools & Environment
| Tool | Version | Purpose |
|------|---------|---------|
| Docker | 25.x | Container runtime |
| Docker Compose | v2.x | Multi-container orchestration |
| Minikube | 1.33.x | Local Kubernetes cluster |
| kubectl | 1.30.x | Kubernetes CLI |

## Folder Structure
```
lab2-containerization-kubernetes/
+-- dockerfiles/
¦   +-- Dockerfile           # Production image
¦   +-- Dockerfile.dev       # Development image
¦   +-- .dockerignore        # Docker build exclusions
¦   +-- docker-compose.yml   # Multi-service compose file
+-- k8s-manifests/
¦   +-- deployment.yaml      # Kubernetes Deployment
¦   +-- service.yaml         # Kubernetes Service
¦   +-- configmap.yaml       # ConfigMap for env vars
¦   +-- hpa.yaml             # Horizontal Pod Autoscaler
+-- scripts/
¦   +-- build-push.sh        # Build and push Docker image
¦   +-- deploy-k8s.sh        # Deploy to Minikube
¦   +-- rollback.sh          # Rollback deployment
+-- screenshots/             # Evidence screenshots
+-- reports/
    +-- lab2-report.md
```

## Experiments Covered
1. Write a Dockerfile and build a container image
2. Run and manage containers (start, stop, logs, exec)
3. Use Docker Compose for multi-service setup
4. Start Minikube and explore the cluster
5. Apply Kubernetes Deployment and Service manifests
6. Scale the deployment and observe pod distribution
7. Perform a rolling update with zero downtime
8. Configure a Horizontal Pod Autoscaler (HPA)

## Quick Commands
```bash
# Build image
docker build -t devops-sample-app:1.0.0 -f dockerfiles/Dockerfile ../../app

# Run with Docker Compose
docker compose -f dockerfiles/docker-compose.yml up -d

# Start Minikube
minikube start --driver=docker

# Deploy to Kubernetes
kubectl apply -f k8s-manifests/

# Scale deployment
kubectl scale deployment devops-app --replicas=3

# Rolling update
kubectl set image deployment/devops-app app=devops-sample-app:2.0.0
```
