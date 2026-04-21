#!/usr/bin/env bash
set -euo pipefail

# Configuration
BRANCH_NAME=${BRANCH_NAME:-"local"}
SHORT_SHA=${SHORT_SHA:-$(date +%Y%m%d-%H%M%S)}
IMAGE=${IMAGE:-"ghcr.io/teknoir/keycloak-themed"}
KEYCLOAK_VERSION=${KEYCLOAK_VERSION:-"26.5.3"}
PLATFORM=${PLATFORM:-"linux/amd64"}
PUSH=${PUSH:-"true"}

# Build arguments
BUILD_ARGS=(
  "--platform=${PLATFORM}"
  "--build-arg" "KEYCLOAK_VERSION=${KEYCLOAK_VERSION}"
  "--tag" "${IMAGE}:${BRANCH_NAME}-${SHORT_SHA}"
)

# Add push flag if enabled
if [ "${PUSH}" = "true" ]; then
  BUILD_ARGS+=("--push")
else
  BUILD_ARGS+=("--load")
fi

# Build the image
echo "Building Keycloak themed image..."
echo "  Base: quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}"
echo "  Tag: ${IMAGE}:${BRANCH_NAME}-${SHORT_SHA}"
echo "  Platform: ${PLATFORM}"
echo "  Push: ${PUSH}"
echo ""

docker buildx build "${BUILD_ARGS[@]}" .

echo ""
echo "Build completed successfully!"
echo "  Image: ${IMAGE}:${BRANCH_NAME}-${SHORT_SHA}"
