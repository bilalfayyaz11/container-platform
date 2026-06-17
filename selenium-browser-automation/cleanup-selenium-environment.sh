#!/usr/bin/env bash

set -euo pipefail

echo "Stopping Selenium container..."

docker stop selenium-chrome || true

echo "Removing Selenium container..."

docker rm selenium-chrome || true

echo "Removing unused Docker resources..."

docker system prune -f

echo "Cleanup completed."
