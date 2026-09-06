#!/bin/bash
export BUILDKIT_PROGRESS=plain
export DOCKER_BUILDKIT=1

set -euo pipefail

cd /home/rva/RVA/current

COMPOSE="docker compose -f docker-compose.production.yml"

echo "==> Building new image (old containers still serving)"
$COMPOSE build --progress=plain app

echo "==> Syncing Mongoid indexes (add declared, drop removed)"
$COMPOSE run --rm --no-deps app \
  bundle exec rake db:mongoid:create_indexes db:mongoid:remove_undefined_indexes

echo "==> Swapping in new app + sidekiq containers"
# app and sidekiq share the freshly built rva-app image, so recreate them
# together to keep the web process and the background worker in sync.
# --no-deps: leave mongo/redis untouched.
$COMPOSE up -d --no-deps app sidekiq

echo "==> Pruning dangling images"
docker image prune -f
