#!/usr/bin/env bash
# Disaster Recovery - Backup & Restore
set -euo pipefail

ACTION="${1:-backup}"
NAMESPACE="${NAMESPACE:-production}"
BACKUP_DIR="./dr-backups/$(date +%Y%m%d-%H%M%S)"

backup() {
    echo "=== DR Backup ==="
    mkdir -p "$BACKUP_DIR"
    for res in deployments services configmaps ingresses hpa; do
        kubectl get ${res} -n ${NAMESPACE} -o yaml > "${BACKUP_DIR}/${res}.yaml" 2>/dev/null || true
        echo "  Saved: ${res}.yaml"
    done
    kubectl get pvc -n ${NAMESPACE} -o yaml > "${BACKUP_DIR}/pvc.yaml" 2>/dev/null || true
    kubectl get deployments -n ${NAMESPACE} \
        -o jsonpath="{.items[*].spec.template.spec.containers[*].image}" \
        | tr " " "\n" > "${BACKUP_DIR}/images.txt"
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"namespace\":\"${NAMESPACE}\"}" \
        > "${BACKUP_DIR}/backup-info.json"
    echo "Backup saved to: $BACKUP_DIR"
    ls -la "$BACKUP_DIR"
}

restore() {
    SRC="${2:-}"
    [[ -z "$SRC" ]] && { echo "Usage: $0 restore <backup-dir>"; exit 1; }
    echo "=== DR Restore from: $SRC ==="
    kubectl apply -f "${SRC}/configmaps.yaml" -n ${NAMESPACE}
    kubectl apply -f "${SRC}/deployments.yaml" -n ${NAMESPACE}
    kubectl apply -f "${SRC}/services.yaml"    -n ${NAMESPACE}
    kubectl apply -f "${SRC}/ingresses.yaml"   -n ${NAMESPACE}
    kubectl rollout status deployment/devops-app-stable -n ${NAMESPACE} --timeout=180s
    echo "Restore complete!"
    kubectl get pods -n ${NAMESPACE}
}

case "$ACTION" in
    backup)  backup ;;
    restore) restore "$@" ;;
    *)       echo "Usage: $0 [backup|restore <dir>]"; exit 1 ;;
esac
