#!/usr/bin/env bash
# Disaster Recovery - Backup & Restore for Capstone
set -euo pipefail

ACTION="${1:-backup}"
NAMESPACE="${NAMESPACE:-capstone}"
BACKUP_DIR="./dr-backups/$(date +%Y%m%d-%H%M%S)"

backup() {
    echo "=== DR Backup: namespace=${NAMESPACE} ==="
    mkdir -p "${BACKUP_DIR}"
    for res in deployments services configmaps ingresses hpa; do
        kubectl get "${res}" -n "${NAMESPACE}" -o yaml > "${BACKUP_DIR}/${res}.yaml" 2>/dev/null || true
        echo "  Saved: ${res}.yaml"
    done
    kubectl get pvc -n "${NAMESPACE}" -o yaml > "${BACKUP_DIR}/pvc.yaml" 2>/dev/null || true
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"namespace\":\"${NAMESPACE}\"}" \
        > "${BACKUP_DIR}/backup-info.json"
    echo "Backup complete: ${BACKUP_DIR}"
    ls -la "${BACKUP_DIR}"
}

restore() {
    SRC="${2:-}"
    [[ -z "$SRC" ]] && { echo "Usage: $0 restore <backup-dir>"; exit 1; }
    echo "=== DR Restore from: ${SRC} ==="
    kubectl apply -f "${SRC}/configmaps.yaml" -n "${NAMESPACE}" || true
    kubectl apply -f "${SRC}/deployments.yaml" -n "${NAMESPACE}"
    kubectl apply -f "${SRC}/services.yaml"    -n "${NAMESPACE}"
    kubectl apply -f "${SRC}/ingresses.yaml"   -n "${NAMESPACE}" || true
    kubectl rollout status deployment/capstone-app -n "${NAMESPACE}" --timeout=180s
    echo "Restore complete!"
    kubectl get pods -n "${NAMESPACE}"
}

case "${ACTION}" in
    backup)  backup ;;
    restore) restore "$@" ;;
    *)       echo "Usage: $0 [backup|restore <dir>]"; exit 1 ;;
esac
