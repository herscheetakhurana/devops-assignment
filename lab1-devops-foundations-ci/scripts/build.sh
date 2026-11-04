#!/usr/bin/env bash
# ============================================================
# Lab 1 - Build Script
# ============================================================
set -euo pipefail

APP_DIR="$(cd "$(dirname "$0")/../../app" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")/.." && pwd)/build"
VERSION="${APP_VERSION:-1.0.0}"

echo "Building devops-sample-app v${VERSION}..."

cd "$APP_DIR"
npm ci
npm test

mkdir -p "$BUILD_DIR"
tar -czf "$BUILD_DIR/devops-sample-app-${VERSION}.tar.gz" \
    --exclude=node_modules \
    --exclude=coverage \
    .

echo "Build artifact: $BUILD_DIR/devops-sample-app-${VERSION}.tar.gz"
echo "Build SUCCESSFUL"
