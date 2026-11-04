#!/usr/bin/env bash
# HashiCorp Vault Secret Management - Lab 4
set -euo pipefail

VAULT_ADDR="${VAULT_ADDR:-http://localhost:8200}"
VAULT_TOKEN="${VAULT_TOKEN:-root}"
export VAULT_ADDR VAULT_TOKEN

init_vault() {
    echo "=== Vault Init ==="
    vault secrets enable -path=devops kv-v2 2>/dev/null || echo "KV already enabled"
    vault kv put devops/app/production \
        DB_PASSWORD="$(openssl rand -base64 32)" \
        API_KEY="$(openssl rand -hex 20)" \
        JWT_SECRET="$(openssl rand -base64 64)"
    echo "Secrets stored at devops/app/production"
}

read_secret() {
    vault kv get -field="${1:-}" devops/app/production 2>/dev/null || \
        vault kv get devops/app/production
}

inject_to_k8s() {
    NS="${1:-production}"
    DB_PASS=$(vault kv get -field=DB_PASSWORD devops/app/production)
    API_KEY=$(vault kv get -field=API_KEY devops/app/production)
    kubectl create secret generic app-secrets \
        --from-literal=DB_PASSWORD="${DB_PASS}" \
        --from-literal=API_KEY="${API_KEY}" \
        -n "${NS}" --dry-run=client -o yaml | kubectl apply -f -
    echo "Secret 'app-secrets' injected into namespace: ${NS}"
}

rotate() {
    vault kv patch devops/app/production \
        API_KEY="$(openssl rand -hex 20)" \
        DB_PASSWORD="$(openssl rand -base64 32)"
    echo "Secrets rotated."
}

case "${1:-help}" in
    init)    init_vault ;;
    read)    read_secret "${2:-}" ;;
    inject)  inject_to_k8s "${2:-production}" ;;
    rotate)  rotate ;;
    *)       echo "Usage: $0 [init|read <key>|inject <ns>|rotate]" ;;
esac
