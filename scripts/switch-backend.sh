#!/bin/bash

set -e

TARGET=$1
NGINX_CONFIG="nginx/default.conf"

if [[ "$TARGET" != "blue" && "$TARGET" != "green" ]]; then
    echo "Usage: ./scripts/switch-backend.sh blue|green"
    exit 1
fi

TARGET_SERVICE="backend-$TARGET"

echo "======================================"
echo " Switching traffic to $TARGET_SERVICE"
echo "======================================"

echo "1. Checking target container..."

CONTAINER_ID=$(docker compose ps -q "$TARGET_SERVICE")

if [ -z "$CONTAINER_ID" ]; then
    echo "ERROR: $TARGET_SERVICE is not running."
    exit 1
fi

echo "2. Checking target health..."

HEALTH=$(docker inspect \
    --format='{{.State.Health.Status}}' \
    "$CONTAINER_ID")

if [ "$HEALTH" != "healthy" ]; then
    echo "ERROR: $TARGET_SERVICE is not healthy."
    exit 1
fi

echo "$TARGET_SERVICE is healthy."

echo "3. Updating Nginx upstream..."

sed -E \
    "s/server backend-(blue|green):8000 resolve;/server $TARGET_SERVICE:8000 resolve;/" \
    "$NGINX_CONFIG" > "${NGINX_CONFIG}.tmp"

cat "${NGINX_CONFIG}.tmp" > "$NGINX_CONFIG"
rm "${NGINX_CONFIG}.tmp"


echo "4. Testing Nginx configuration..."

docker exec ecommerce-nginx nginx -t

echo "5. Gracefully reloading Nginx..."

docker exec ecommerce-nginx nginx -s reload

sleep 2

echo "6. Verifying application..."

curl -fsS http://localhost/api/health > /dev/null

echo ""
echo "Traffic successfully switched to $TARGET_SERVICE!"
echo "======================================"
