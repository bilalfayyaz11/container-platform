#!/bin/bash

COMPOSE_FILE="docker-compose-production.yml"

case "$1" in
    start)
        echo "Starting ELK Stack..."
        docker compose -f "$COMPOSE_FILE" up -d
        echo "Waiting for services to initialize..."
        sleep 30
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    stop)
        echo "Stopping ELK Stack..."
        docker compose -f "$COMPOSE_FILE" down
        ;;
    restart)
        echo "Restarting ELK Stack..."
        docker compose -f "$COMPOSE_FILE" restart
        ;;
    status)
        echo "ELK Stack Status:"
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    logs)
        if [ -z "$2" ]; then
            docker compose -f "$COMPOSE_FILE" logs -f
        else
            docker compose -f "$COMPOSE_FILE" logs -f "$2"
        fi
        ;;
    cleanup)
        echo "Cleaning up ELK Stack..."
        docker compose -f "$COMPOSE_FILE" down -v
        docker system prune -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs [service]|cleanup}"
        exit 1
        ;;
esac
