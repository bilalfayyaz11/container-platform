# Docker Custom Network Design

## Network Layout

- webapp-network: shared web application bridge network
- frontend-network: frontend-facing service network
- backend-network: application backend network with custom subnet
- database-network: isolated database-tier network

## Purpose

This design separates containers by application tier instead of placing every container on the default bridge network. It improves isolation, enables container DNS resolution, and supports controlled multi-network communication.
