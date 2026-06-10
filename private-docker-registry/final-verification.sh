#!/bin/bash
set +e
echo "=== Final Registry Verification ==="
curl -k -u testuser:testpass https://localhost:5000/v2/_catalog >/dev/null 2>&1 && echo "PASS: Authentication working" || echo "FAIL: Authentication failed"
sudo docker pull alpine:3.20 >/dev/null 2>&1
sudo docker tag alpine:3.20 localhost:5000/test-alpine:latest
sudo docker push localhost:5000/test-alpine:latest >/dev/null 2>&1 && echo "PASS: Push working" || echo "FAIL: Push failed"
sudo docker rmi localhost:5000/test-alpine:latest >/dev/null 2>&1
sudo docker pull localhost:5000/test-alpine:latest >/dev/null 2>&1 && echo "PASS: Pull working" || echo "FAIL: Pull failed"
[ -d /opt/docker-registry/data/docker ] && echo "PASS: Registry data persisted" || echo "FAIL: Registry data missing"
