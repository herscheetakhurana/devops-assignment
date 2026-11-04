#!/usr/bin/env bash
# Rollback Kubernetes deployment to previous revision
set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
DEPLOY="devops-app"

echo "Rolling back deployment: ${DEPLOY}"
kubectl rollout undo deployment/${DEPLOY} -n ${NAMESPACE}

echo "Rollout status:"
kubectl rollout status deployment/${DEPLOY} -n ${NAMESPACE}

echo "Current pods:"
kubectl get pods -n ${NAMESPACE} -l app=devops-app

echo "Rollback complete."
