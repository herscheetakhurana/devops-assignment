#!/usr/bin/env bash
# ============================================================
# Capstone Deployment Script
# Usage: ./deploy.sh [build|push|deploy|scan|all] [version]
# ============================================================
set -euo pipefail

ACTION="${1:-all}"
VERSION="${2:-1.0.0}"
IMAGE="devops-capstone-app:${VERSION}"
NAMESPACE="capstone"

build() {
    echo "=== Building Docker image: ${IMAGE} ==="
    docker build \
        -t "${IMAGE}" \
        --build-arg BUILD_VERSION="${VERSION}" \
        -f docker/Dockerfile .
    echo "Build complete: ${IMAGE}"
    docker images "${IMAGE}"
}

scan() {
    echo "=== Running Trivy Security Scan: ${IMAGE} ==="
    trivy image \
        --severity CRITICAL,HIGH \
        --format table \
        --output "logs/trivy-scan-${VERSION}.txt" \
        "${IMAGE}" || true
    echo "Scan complete. Report: logs/trivy-scan-${VERSION}.txt"
}

push() {
    echo "=== Pushing to registry ==="
    docker push "${IMAGE}"
    docker push "devops-capstone-app:latest"
}

deploy() {
    echo "=== Deploying to Kubernetes namespace: ${NAMESPACE} ==="
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/deployment.yaml
    kubectl apply -f k8s/service.yaml
    kubectl apply -f k8s/hpa.yaml
    kubectl set image deployment/capstone-app app="${IMAGE}" -n "${NAMESPACE}"
    kubectl rollout status deployment/capstone-app -n "${NAMESPACE}" --timeout=180s
    echo "=== Deployment complete ==="
    kubectl get pods -n "${NAMESPACE}"
}

verify() {
    echo "=== Verifying deployment ==="
    sleep 10
    APP_URL=$(minikube service capstone-service-nodeport --url -n "${NAMESPACE}" 2>/dev/null || echo "http://localhost:3000")
    curl -sf "${APP_URL}/health" && echo " Health check PASSED"
    curl -sf "${APP_URL}/api/status" && echo " API status PASSED"
}

case "${ACTION}" in
    build)   build ;;
    scan)    scan ;;
    push)    push ;;
    deploy)  deploy ;;
    verify)  verify ;;
    all)     build; scan; deploy; verify ;;
    *)       echo "Usage: $0 [build|push|deploy|scan|verify|all] [version]"; exit 1 ;;
esac
