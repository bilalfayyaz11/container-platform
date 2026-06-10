#!/usr/bin/env bash
set -euo pipefail

docker rm -f \
  debug-container \
  network-test \
  debug-app-custom \
  debug-client-custom \
  interactive-container \
  shell-container \
  broken-container \
  problematic-app \
  memory-limited \
  port-conflict-test 2>/dev/null || true

docker network rm debug-network 2>/dev/null || true

docker rmi \
  debug-app \
  broken-app \
  debug-problematic 2>/dev/null || true

docker system df
