#!/usr/bin/env bash
# Blue-green deployment: start the idle color with the new image,
# switch nginx to it, then stop the old color.
#
# Usage: ./deploy.sh <image>
#   e.g. ./deploy.sh ghcr.io/owner/repo:v12
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="${1:?usage: deploy.sh <image>}"
UPSTREAM=nginx/upstream.inc

# 1. Find the active color from the nginx upstream file.
if grep -q blue "$UPSTREAM"; then
  CURRENT=blue; NEXT=green
else
  CURRENT=green; NEXT=blue
fi
echo "active: $CURRENT -> deploying: $NEXT"

# 2. Pull the new image and tag it with the name compose.yaml uses.
#    The running container keeps using the old image until it is recreated.
sudo docker pull "$IMAGE"
sudo docker tag "$IMAGE" seminar-app:latest

# 3. Start the idle color with the new image.
sudo docker compose up -d --force-recreate "$NEXT"

# 4. Wait until the new container answers (max 60s).
for i in $(seq 1 30); do
  if sudo docker compose exec -T nginx wget -qO- "http://$NEXT:8080/api/hello" > /dev/null 2>&1; then
    echo "$NEXT is ready"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "$NEXT did not become ready; keeping $CURRENT active" >&2
    sudo docker compose stop "$NEXT"
    exit 1
  fi
  sleep 2
done

# 5. Point nginx at the new color and reload without dropping connections.
echo "server $NEXT:8080;" > "$UPSTREAM"
sudo docker compose exec -T nginx nginx -t
sudo docker compose exec -T nginx nginx -s reload

# 6. Stop the old color.
sudo docker compose stop "$CURRENT"
echo "switched: $CURRENT -> $NEXT"
