# Docker Network Connectivity Results

## Successful Communication

- web-client reached web-server through webapp-network.
- frontend-app reached app-server through frontend-network.
- app-server resolved and reached mysql-db through backend-network.

## Blocked Communication

- frontend-app could not reach mysql-db directly because it is not attached to backend-network.
- web-client could not reach mysql-db because webapp-network and backend-network are isolated.

## Key Finding

Custom Docker bridge networks provide built-in DNS resolution only between containers attached to the same user-defined network. Containers on separate networks are isolated unless explicitly connected to a shared network.
