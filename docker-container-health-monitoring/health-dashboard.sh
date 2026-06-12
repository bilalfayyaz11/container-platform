#!/bin/bash

echo "=========================================="
echo "    Docker Health Check Dashboard"
echo "=========================================="
echo "Timestamp: $(date)"
echo

for container in $(docker ps -a --format '{{.Names}}')
do
    if docker inspect "$container" --format='{{json .Config.Healthcheck}}' | grep -q "Test"
    then
        echo "Container: $container"
        echo "  Runtime Status: $(docker inspect "$container" --format='{{.State.Status}}')"
        echo "  Health Status: $(docker inspect "$container" --format='{{.State.Health.Status}}')"
        echo "  Failing Streak: $(docker inspect "$container" --format='{{.State.Health.FailingStreak}}')"
        echo "  Restart Count: $(docker inspect "$container" --format='{{.RestartCount}}')"
        echo
    fi
done

echo "=========================================="
