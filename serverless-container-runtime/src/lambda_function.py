import json
import datetime
import os
import sys


def lambda_handler(event, context):
    """
    Container-based AWS Lambda handler for HTTP-style requests.
    """

    current_time = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

    http_method = event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method", "UNKNOWN")
    path = event.get("path") or event.get("rawPath", "/")
    query_params = event.get("queryStringParameters") or {}

    response_data = {
        "message": "Hello from a containerized Lambda runtime",
        "timestamp": current_time,
        "method": http_method,
        "path": path,
        "query_parameters": query_params,
        "container_info": {
            "python_version": sys.version,
            "environment": os.environ.get("AWS_EXECUTION_ENV", "local-container")
        }
    }

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(response_data, indent=2)
    }
