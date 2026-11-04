#!/usr/bin/env bash
# Build and push Docker image to registry
set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-devops-sample-app}"
TAG="${TAG:-1.0.0}"
REGISTRY="${REGISTRY:-docker.io/yourusername}"

echo "Building image: ${IMAGE_NAME}:${TAG}"
docker build \
    -t "${IMAGE_NAME}:${TAG}" \
    -t "${IMAGE_NAME}:latest" \
    -f dockerfiles/Dockerfile \
    ../../app

echo "Tagging for registry..."
docker tag "${IMAGE_NAME}:${TAG}" "${REGISTRY}/${IMAGE_NAME}:${TAG}"
docker tag "${IMAGE_NAME}:${TAG}" "${REGISTRY}/${IMAGE_NAME}:latest"

echo "Pushing to registry..."
docker push "${REGISTRY}/${IMAGE_NAME}:${TAG}"
docker push "${REGISTRY}/${IMAGE_NAME}:latest"

echo "Done! Image: ${REGISTRY}/${IMAGE_NAME}:${TAG}"
