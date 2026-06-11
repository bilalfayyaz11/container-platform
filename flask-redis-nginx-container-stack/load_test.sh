#!/bin/bash

set -e

echo "Starting load test..."
echo

echo "Testing main page through Nginx..."
for i in {1..10}; do
    printf "Request %02d: " "$i"
    curl -s -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n" http://localhost/
    sleep 1
done

echo
echo "Testing health endpoint..."
for i in {1..5}; do
    printf "Health check %02d: " "$i"
    curl -s http://localhost/health | jq -r '.status'
    sleep 1
done

echo
echo "Testing stats endpoint..."
curl -s http://localhost/stats | jq

echo
echo "Load test completed."
