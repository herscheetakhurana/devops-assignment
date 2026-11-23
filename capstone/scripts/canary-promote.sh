#!/usr/bin/env bash
# Canary Full Promotion for Capstone
# Usage: ./canary-promote.sh <new-version>
set -euo pipefail

NEW_VERSION="${1:-2.0.0}"
NAMESPACE="${NAMESPACE:-capstone}"

echo "=== Canary Promotion: v${NEW_VERSION} ==="
echo "[1/4] Updating stable to v${NEW_VERSION}..."
kubectl set image deployment/capstone-stable \
    app="devops-capstone-app:${NEW_VERSION}" -n "${NAMESPACE}"
kubectl rollout status deployment/capstone-stable -n "${NAMESPACE}" --timeout=120s

echo "[2/4] Scaling stable to 9 replicas..."
kubectl scale deployment capstone-stable --replicas=9 -n "${NAMESPACE}"

echo "[3/4] Scaling canary to 0..."
kubectl scale deployment capstone-canary --replicas=0 -n "${NAMESPACE}"

echo "[4/4] Promotion complete! v${NEW_VERSION} at 100%."
kubectl get deployments -n "${NAMESPACE}" | grep capstone
