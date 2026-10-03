#!/bin/bash

set -e

NGINX_CONFIG="nginx/default.conf"

echo "======================================"
echo " Blue/Green E-Commerce Rollback"
echo "======================================"

# Detect current active backend
if grep -q "server backend-blue:8000" "$NGINX_CONFIG"; then
    ACTIVE="backend-blue"
    ROLLBACK_TARGET="backend-green"
else
    ACTIVE="backend-green"
    ROLLBACK_TARGET="backend-blue"
fi

echo "Current active backend : $ACTIVE"
echo "Rollback target        : $ROLLBACK_TARGET"
echo ""

echo "1. Checking rollback target..."

CONTAINER_ID=$(docker compose ps -q "$ROLLBACK_TARGET")

if [ -z "$CONTAINER_ID" ]; then
    echo "Rollback FAILED!"
    echo "$ROLLBACK_TARGET is not running."
    exit 1
fi

echo "2. Checking rollback target health..."

HEALTH=$(docker inspect \
    --format='{{.State.Health.Status}}' \
    "$CONTAINER_ID" 2>/dev/null || echo "unknown")

if [ "$HEALTH" != "healthy" ]; then
    echo "Rollback FAILED!"
    echo "$ROLLBACK_TARGET is not healthy."
    echo "Traffic remains on $ACTIVE."
    exit 1
fi

echo "$ROLLBACK_TARGET is healthy."

echo "3. Switching traffic to previous environment..."

./scripts/switch-backend.sh "${ROLLBACK_TARGET#backend-}"

echo "4. Verifying production health..."

if curl -fsS http://localhost/api/health > /dev/null; then
    echo ""
    echo "Rollback successful!"
    echo "Traffic is now running on $ROLLBACK_TARGET."
    echo "$ACTIVE remains available."
else
    echo ""
    echo "Rollback verification FAILED!"
    exit 1
fi

echo "======================================"
echo " Rollback Complete"
echo "======================================"