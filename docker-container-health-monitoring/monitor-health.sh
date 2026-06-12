#!/bin/bash

echo "Docker Container Health Monitor"
echo "==============================="

containers=("healthcheck-advanced" "failing-container")

for container in "${containers[@]}"
do
    if docker ps -a --format '{{.Names}}' | grep -qx "$container"
    then
        echo
        echo "Container: $container"
        echo "Status: $(docker inspect "$container" --format='{{.State.Status}}')"
        echo "Health Status: $(docker inspect "$container" --format='{{.State.Health.Status}}')"
        echo "Failing Streak: $(docker inspect "$container" --format='{{.State.Health.FailingStreak}}')"
        echo "Restart Count: $(docker inspect "$container" --format='{{.RestartCount}}')"
        echo "Last Health Check:"
        docker inspect "$container" --format='{{range .State.Health.Log}}{{.Start}} | Exit: {{.ExitCode}} | {{.Output}}{{end}}' | tail -1
    else
        echo "Container $container does not exist"
    fi
done
