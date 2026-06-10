# Container Network Placement

## Containers

- web-server: attached to webapp-network
- web-client: attached to webapp-network
- mysql-db: attached to backend-network
- app-server: attached to backend-network and frontend-network
- frontend-app: attached to frontend-network

## Design Logic

The app-server acts as a bridge between frontend and backend tiers. The database stays isolated inside the backend network, while frontend containers cannot directly reach backend-only services unless connected through an approved multi-network service.
