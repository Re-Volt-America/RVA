#!/bin/bash
set -euo pipefail

cd /home/rva/RVA/current

COMPOSE="docker compose -f docker-compose.production.yml"

echo "==> Building new app image (old container still serving)"
$COMPOSE build app

echo "==> Swapping in new app container"
# --no-deps: leave mongo/redis untouched
$COMPOSE up -d --no-deps app

echo "==> Pruning dangling images"
docker image prune -f
