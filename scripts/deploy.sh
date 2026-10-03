#!/bin/bash

set -e

NGINX_CONFIG="nginx/default.conf"

echo "======================================"
echo " Blue/Green E-Commerce Deployment"
echo "======================================"

# Detect current active backend
if grep -q "server backend-blue:8000" "$NGINX_CONFIG"; then
    ACTIVE="backend-blue"
    INACTIVE="backend-green"
else
    ACTIVE="backend-green"
    INACTIVE="backend-blue"
fi

echo "Current active backend : $ACTIVE"
echo "Deployment target      : $INACTIVE"
echo ""

echo "1. Building new version on $INACTIVE..."
docker compose build "$INACTIVE"

echo "2. Recreating inactive backend..."
docker compose up -d --no-deps --force-recreate "$INACTIVE"

echo "3. Waiting for $INACTIVE to become healthy..."

CONTAINER_ID=$(docker compose ps -q "$INACTIVE")
HEALTH="starting"

for i in {1..24}; do
    HEALTH=$(docker inspect \
        --format='{{.State.Health.Status}}' \
        "$CONTAINER_ID" 2>/dev/null || echo "starting")

    echo "Health status: $HEALTH"

    if [ "$HEALTH" = "healthy" ]; then
        break
    fi

    sleep 5
done

if [ "$HEALTH" != "healthy" ]; then
    echo "Deployment FAILED!"
    echo "$INACTIVE did not become healthy."
    echo "Traffic remains on $ACTIVE."
    exit 1
fi

echo "$INACTIVE is healthy."

echo "4. Switching production traffic..."

./scripts/switch-backend.sh "${INACTIVE#backend-}"

echo "5. Running final health check..."

if curl -fsS http://localhost/api/health > /dev/null; then
    echo ""
    echo "Deployment successful!"
    echo "Traffic is now running on $INACTIVE."
    echo "$ACTIVE remains available for rollback."
else
    echo "Deployment verification FAILED!"
    exit 1
fi

echo "======================================"
echo " Deployment Complete"
echo "======================================"