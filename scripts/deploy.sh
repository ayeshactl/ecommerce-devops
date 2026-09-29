#!/bin/bash

set -e

echo "======================================"
echo " Starting E-Commerce Deployment"
echo "======================================"

echo "1. Building Docker images..."
docker compose build

echo "2. Starting/updating containers..."
docker compose up -d --scale backend=2

echo "3. Waiting for services to stabilize..."
sleep 10

echo "4. Checking backend health..."
if curl -fsS http://localhost/api/health > /dev/null; then
    echo "Deployment successful!"
    echo "Backend health check passed."
else
    echo "Deployment failed!"
    echo "Backend health check did not pass."
    exit 1
fi

echo "======================================"
echo " Deployment Complete"
echo "======================================"
