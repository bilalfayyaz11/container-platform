#!/bin/bash

curl -X PUT "localhost:9200/_index_template/docker-logs-template" \
-H 'Content-Type: application/json' \
-d '{
  "index_patterns": ["docker-logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 0
    },
    "mappings": {
      "properties": {
        "@timestamp": {
          "type": "date"
        },
        "container_name": {
          "type": "keyword"
        },
        "log_level": {
          "type": "keyword"
        },
        "message": {
          "type": "text",
          "analyzer": "standard"
        }
      }
    }
  }
}'
