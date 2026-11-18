#!/usr/bin/env bash
# Send a request to /api/hello every second and print each response.
# Keep this running during a deployment to see that no request fails.
#
# Usage: ./watch.sh [url]
#   e.g. ./watch.sh                          (default: http://localhost/api/hello)
#        ./watch.sh http://1.2.3.4/api/hello
# Stop with Ctrl+C.

URL="${1:-http://localhost/api/hello}"
ok=0
fail=0

# Print a summary when stopped.
trap 'echo; echo "total: $((ok + fail))  ok: $ok  failed: $fail"; exit 0' INT

while true; do
  # --max-time keeps a hung request from blocking the loop.
  if body=$(curl -sf --max-time 2 "$URL"); then
    ok=$((ok + 1))
    echo "$(date +%H:%M:%S)  $body"
  else
    fail=$((fail + 1))
    echo "$(date +%H:%M:%S)  FAILED"
  fi
  sleep 1
done
