#!/usr/bin/env bash
# ============================================================
# Lab 3 - Container Security Scanning with Trivy
# ============================================================
set -euo pipefail

IMAGE="${1:-devops-sample-app:1.0.0}"
REPORT_DIR="$(cd "$(dirname "$0")/../reports" && pwd)"
REPORT_FILE="$REPORT_DIR/trivy-scan-$(date +%Y%m%d-%H%M%S).txt"

echo "==============================="
echo " Security Scan: $IMAGE"
echo "==============================="

# Install Trivy if not present
if ! command -v trivy &>/dev/null; then
    echo "Installing Trivy..."
    wget -qO- https://aquasecurity.github.io/trivy-repo/deb/public.key | \
        sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb generic main | \
        sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update && sudo apt-get install -y trivy
fi

echo "Running vulnerability scan..."
trivy image \
    --format table \
    --severity HIGH,CRITICAL \
    --output "$REPORT_FILE" \
    "$IMAGE"

echo ""
echo "Scan Summary:"
trivy image --severity CRITICAL --format json "$IMAGE" | \
    python3 -c "import sys,json; d=json.load(sys.stdin); \
    vulns=[v for r in d.get('Results',[]) for v in r.get('Vulnerabilities',[])] if d.get('Results') else []; \
    print(f'CRITICAL vulnerabilities: {len(vulns)}')"

echo ""
echo "Full report saved to: $REPORT_FILE"
