#!/usr/bin/env bash
# ============================================================
# Lab 1 - Test Runner Script
# ============================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/../../app" && pwd)"

echo "Running tests for devops-sample-app..."
cd "$APP_DIR"
npm test -- --coverage --verbose

echo ""
echo "All tests passed!"
