#!/usr/bin/env bash
# Canary Full Promotion
# Usage: ./canary-promote.sh <new-version>
set -euo pipefail

NEW_VERSION="${1:-2.0.0}"
NAMESPACE="${NAMESPACE:-production}"

echo "=== Canary Promotion: v${NEW_VERSION} ==="

echo "[1/4] Updating stable to v${NEW_VERSION}..."
kubectl set image deployment/devops-app-stable \
    app=devops-sample-app:${NEW_VERSION} -n ${NAMESPACE}
kubectl rollout status deployment/devops-app-stable -n ${NAMESPACE} --timeout=120s

echo "[2/4] Scaling stable to 9 replicas..."
kubectl scale deployment devops-app-stable --replicas=9 -n ${NAMESPACE}

echo "[3/4] Scaling canary to 0..."
kubectl scale deployment devops-app-canary --replicas=0 -n ${NAMESPACE}

echo "[4/4] Removing canary ingress weight..."
kubectl annotate ingress devops-app-ingress \
    nginx.ingress.kubernetes.io/canary-weight- --overwrite -n ${NAMESPACE} 2>/dev/null || true

echo "Promotion complete! v${NEW_VERSION} is 100% stable."
kubectl get deployments -n ${NAMESPACE} | grep devops-app
