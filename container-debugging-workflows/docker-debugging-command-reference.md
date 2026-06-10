# Docker Debugging Command Reference

## Log Analysis
docker logs container-name
docker logs -f container-name
docker logs --tail 50 container-name
docker logs --since 1h container-name
docker logs container-name 2>&1 | grep -i error

## Runtime Inspection
docker exec container-name ps aux
docker exec container-name df -h
docker exec container-name env
docker exec -it container-name bash

## Network Debugging
docker inspect container-name
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container-name
docker network ls
docker network inspect bridge
docker exec container-name netstat -tlnp
docker exec container-name curl http://localhost:port

## Startup Failure Debugging
docker ps -a
docker logs container-name
docker inspect container-name

## Resource Debugging
docker stats container-name --no-stream
docker system df
docker system info
