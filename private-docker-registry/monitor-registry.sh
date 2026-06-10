#!/bin/bash
echo "=== Registry Monitoring Report ==="
echo "Date: $(date)"
echo
echo "Registry Container Status:"
sudo docker ps | grep registry || true
echo
echo "Registry Storage Usage:"
du -sh /opt/docker-registry/data
echo
echo "Registry Repositories:"
curl -s -k -u testuser:testpass https://localhost:5000/v2/_catalog | jq -r ".repositories[]" 2>/dev/null || echo "No repositories found"
echo
echo "Docker System Information:"
sudo docker system df
