#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: ./scripts/rollback.sh <commit-id>"
    echo ""
    echo "Recent commits:"
    git log --oneline -5
    exit 1
fi

TARGET_COMMIT=$1

echo "======================================"
echo " Starting Rollback"
echo " Target commit: $TARGET_COMMIT"
echo "======================================"

# Make sure the commit exists
git rev-parse --verify "$TARGET_COMMIT^{commit}" > /dev/null

# Do not rollback if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Rollback stopped!"
    echo "Uncommitted changes exist. Commit or stash them first."
    exit 1
fi

echo "1. Switching to target version..."
git checkout "$TARGET_COMMIT"

echo "2. Rebuilding containers..."
docker compose build

echo "3. Starting target version..."
docker compose up -d --scale backend=2

echo "4. Waiting for services..."
sleep 10

echo "5. Checking application health..."
if curl -fsS http://localhost/api/health > /dev/null; then
    echo "Rollback successful!"
    echo "Application is healthy."
else
    echo "Rollback completed, but health check FAILED!"
    exit 1
fi

echo "======================================"
echo " Rollback Complete"
echo "======================================"
