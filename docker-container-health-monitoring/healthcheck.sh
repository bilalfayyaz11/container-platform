#!/bin/bash

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health)

if [ "$HTTP_CODE" -eq 200 ]
then
    echo "healthy"
    exit 0
else
    echo "unhealthy"
    exit 1
fi
