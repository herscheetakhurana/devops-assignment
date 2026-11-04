#!/usr/bin/env bash
# Deploy to Minikube Kubernetes cluster
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"

echo "==============================="
echo " Deploying to Minikube"
echo "==============================="

# Ensure Minikube is running
minikube status || minikube start --driver=docker

# Load local image into Minikube
echo "Loading image into Minikube..."
minikube image load devops-sample-app:${IMAGE_TAG}

# Apply manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s-manifests/configmap.yaml -n ${NAMESPACE}
kubectl apply -f k8s-manifests/deployment.yaml -n ${NAMESPACE}
kubectl apply -f k8s-manifests/service.yaml -n ${NAMESPACE}
kubectl apply -f k8s-manifests/hpa.yaml -n ${NAMESPACE}

# Wait for rollout
echo "Waiting for deployment rollout..."
kubectl rollout status deployment/devops-app -n ${NAMESPACE} --timeout=120s

# Show status
kubectl get pods -n ${NAMESPACE} -l app=devops-app
kubectl get svc devops-app-service -n ${NAMESPACE}

echo ""
echo "App URL: $(minikube service devops-app-service --url)"
