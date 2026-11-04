#!/usr/bin/env bash
# Blue-Green Traffic Switch
# Usage: ./blue-green-switch.sh [blue|green]
set -euo pipefail

TARGET="${1:-green}"
NAMESPACE="${NAMESPACE:-production}"
SERVICE="devops-app-active"

[[ "$TARGET" != "blue" && "$TARGET" != "green" ]] && { echo "Error: must be blue or green"; exit 1; }

echo "=== Blue-Green Switch: target=$TARGET ==="
READY=$(kubectl get deployment devops-app-${TARGET} -n ${NAMESPACE} \
    -o jsonpath="{.status.readyReplicas}" 2>/dev/null || echo "0")

[[ "$READY" -lt 1 ]] && { echo "ERROR: ${TARGET} slot has no ready pods!"; exit 1; }
echo "${TARGET} slot has ${READY} ready pods."

kubectl patch service ${SERVICE} -n ${NAMESPACE} \
    -p "{\"spec\":{\"selector\":{\"app\":\"devops-app\",\"slot\":\"${TARGET}\"}}}"

kubectl annotate service ${SERVICE} -n ${NAMESPACE} \
    "deployment.kubernetes.io/active-slot=${TARGET}" --overwrite

sleep 5
kubectl get endpoints ${SERVICE} -n ${NAMESPACE}
echo "Traffic switched to: ${TARGET}"
