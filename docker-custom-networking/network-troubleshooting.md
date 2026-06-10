# Docker Network Troubleshooting

## Isolated Container Test

A container started with `--network none` has no external network connectivity. This is useful for security-sensitive workloads or for testing strict isolation.

## Disconnect Test

The app-server was disconnected from frontend-network. After disconnecting, frontend-app could no longer resolve or reach app-server.

## Reconnect Test

After reconnecting app-server to frontend-network, DNS resolution and connectivity were restored.

## Commands Used

- docker network disconnect
- docker network connect
- docker network inspect
- docker exec
- ip route
- ip addr show
- nslookup
- iptables

## Production Relevance

These commands help troubleshoot broken service discovery, missing network attachments, incorrect network segmentation, DNS failures, and unexpected container isolation.
