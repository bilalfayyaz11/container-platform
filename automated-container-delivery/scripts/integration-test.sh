#!/usr/bin/env bash
set -euo pipefail

echo "Starting integration tests..."

wait_for_service() {
  local url="$1"
  local service_name="$2"
  local max_attempts=30
  local attempt=1

  echo "Waiting for $service_name..."

  while [ "$attempt" -le "$max_attempts" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "$service_name is ready."
      return 0
    fi

    echo "Attempt $attempt/$max_attempts: $service_name not ready yet."
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "$service_name failed readiness check."
  return 1
}

echo "Test 1: App health endpoint"
wait_for_service "http://localhost:3000/health" "App"

echo "Test 2: App root endpoint"
response="$(curl -fsS http://localhost:3000/)"

if echo "$response" | grep -q "automated container delivery pipeline"; then
  echo "App root endpoint passed."
else
  echo "App root endpoint failed."
  echo "Response: $response"
  exit 1
fi

echo "Test 3: Nginx proxy health endpoint"
wait_for_service "http://localhost:8080/health" "Nginx proxy"

echo "Test 4: Simple load check"
for i in {1..10}; do
  curl -fsS http://localhost:3000/ >/dev/null
done

echo "All integration tests passed."
